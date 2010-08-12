require 'singleton'

class DraftingService

  include Singleton

  @@min_quorum = 50
  @@min_votes  = 5
  @@time_ready  = 10.hours # 10 hours
  @@time_approved  = 10.hours # 10 hours
  @@time_approval_reminder  = 6.hours #6 hours

  def self.min_quorum=(value)
    @@min_quorum = value
  end

  def self.min_votes=(value)
    @@min_votes = value
  end

  def self.time_ready=(value)
    @@time_ready = value
  end

  def self.time_approved=(value)
    @@time_approved = value
  end

  def self.time_approval_reminder=(value)
    @@time_approval_reminder = value
  end

  def update(*args)
    send(*args)
  end

  # observer to echoable support action
  def supported(echoable, user)
    draft(echoable, echoable.supporter_count.to_i-1)
  end

  # observer to echoable unsupport action
  def unsupported(echoable, user)
    draft(echoable, echoable.supporter_count.to_i+1)
  end

  # observer to incorporable incorporated action
  def incorporated(incorporable, user)
    incorporate(incorporable, user)
    select_approved(incorporable)
  end

  def stage(incorporable)
    set_stage(incorporable)
    incorporable.reload
    select_approved(incorporable)
  end

  # select a suitable sibling from the incorporable to become approved
  def select_approved(incorporable)
    if incorporable.parent.approved_children.empty?
      siblings = incorporable.siblings.select{|s|s.staged?}
      approve(siblings.first) if !siblings.empty?
    end
  end

  def reset_incorporable(incorporable)
    EchoService.instance.reset_echoable(incorporable)
    incorporable.update_attribute(:times_passed, 0)
    set_track(incorporable)
  end

  def send_approved_email(incorporable)
    statement_document = incorporable.original_document
    if incorporable.times_passed == 0
      email = NotificationMailer.create_approval(incorporable, statement_document)
      NotificationMailer.deliver(email)
    elsif incorporable.times_passed == 1
      supporters = incorporable.supporters.select{|supporter|
        supporter.speaks_language?(incorporable.original_language, 'intermediate')
      }
      email = NotificationMailer.create_supporters_approval(incorporable, statement_document, supporters)
      NotificationMailer.deliver(email)
    end

    Delayed::Job.enqueue ApprovalReminderMailJob.new(incorporable.id, incorporable.state_since), 1, Time.now + @@time_approval_reminder
    #Send approval notification to the proposal supporters
    supporters = incorporable.parent.supporters.select{|supporter|
      supporter.languages.include?(incorporable.original_language)
    }
    email = ActivityTrackingMailer.create_approval_notification(incorporable, statement_document, supporters)
    ActivityTrackingMailer.deliver(email)
  end

  def send_approval_reminder(incorporable)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_approval_reminder(incorporable, statement_document)
    NotificationMailer.deliver(email)
  end

  def send_supporters_approval_reminder(incorporable)
    statement_document = incorporable.original_document
    supporters = incorporable.supporters.select{|supporter|
      supporter.speaks_language?(incorporable.original_language, 'intermediate')
    }
    email = NotificationMailer.create_supporters_approval_reminder(incorporable, statement_document, supporters)
    NotificationMailer.deliver(email)
  end

  def send_passed_email(incorporable)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_passed(statement_document)
    NotificationMailer.deliver(email)
  end

  def send_supporters_passed_email(incorporable)
    statement_document = incorporable.original_document
    supporters = incorporable.supporters.select{|supporter|
      supporter.speaks_language?(incorporable.original_language, 'intermediate')
    }
    email = NotificationMailer.create_supporters_passed(statement_document, supporters)
    NotificationMailer.deliver(email)
  end

  def send_incorporated_email(incorporable, user)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_incorporated(incorporable, statement_document)
    NotificationMailer.deliver(email)
  end

  private

  # kickstarts the drafting process, i e when it's incorporable updates the sibling states, when drafteable,
  # adjust the readiness of the children
  def draft(echoable, old_supporter_count)
    if echoable.incorporable?
      siblings = echoable.siblings
      update_incorporable_states(siblings, echoable, old_supporter_count)
    elsif echoable.drafteable?
      children = echoable.sorted_children
      children.each do |child|
        adjust_readiness(child, false, false)
      end
    end
  end

  # calculate which incorporable's positions (ordered per supported_count) have changed, and update their states
  def update_incorporable_states(incorporables, changed_incorporable, old_supporter_count)
    old_order = incorporables.map{|s|[s.id, s.supporter_count.to_i]} # get array order with id and supporter count
    old_order[incorporables.index(changed_incorporable)][1] = old_supporter_count # set the old supporter count on the changed incorporable
    old_order.sort!{|a, b| b[1] <=> a[1]} #sort the array, thus getting the ordered array before the support/unsupport action)
    old_order.map!{|s|s[0]}
    incorporables.each_with_index do |incorporable, index|
      if index != old_order.index(incorporable.id) or incorporable.eql?(changed_incorporable)
        adjust_readiness(incorporable, index > old_order.index(incorporable.id), incorporable == changed_incorporable)
      end
    end
  end

  # according to the given parameters, will either readify or track the incorporable
  def adjust_readiness(incorporable, position_decreased, changed_criteria)
    readiness = test_readiness(incorporable)
    if ((incorporable.tracked? and changed_criteria) or (!incorporable.tracked? and position_decreased)) and
        readiness
        readify(incorporable)
    elsif !incorporable.tracked? and changed_criteria and !readiness
      track(incorporable)
    end
  end

  # test if incorporable fulfills all conditions to become ready
  def test_readiness(incorporable)
    incorporable.supporter_count >= @@min_votes# and incorporable.quorum >= @@min_quorum
  end

  # set incorporable state as tracked
  def track(incorporable)
    set_track(incorporable)
  end

  # set incorporable as ready
  def readify(incorporable)
    set_readify(incorporable)
    incorporable.reload
    Delayed::Job.enqueue TestForStagedJob.new(incorporable.id,incorporable.state_since), 1, Time.now.advance(:seconds => @@time_ready)
  end

  # set incorporable as approved
  def approve(incorporable)
    set_approve(incorporable)
    incorporable.reload
    send_approved_email(incorporable)
    Delayed::Job.enqueue TestForPassedJob.new(incorporable.id), 1, Time.now.advance(:seconds => @@time_approved)
  end

  def incorporate(incorporable, user)
    set_incorporate(incorporable)
    incorporable.reload
    send_incorporated_email(incorporable, user)
  end

  %w(track readify stage approve incorporate).each do |transition|
    class_eval %(
      def set_#{transition}(incorporable)
        incorporable.state_since=Time.now
        incorporable.send('#{transition}!')
        incorporable.save
      end
    )
  end
end