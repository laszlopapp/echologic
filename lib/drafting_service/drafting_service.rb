require 'singleton'

class DraftingService

  include Singleton

  ##############
  # Parameters #
  ##############

  @@min_quorum = 50
  @@min_votes  = 5
  @@time_ready  = 10.hours
  @@time_approved  = 10.hours
  @@time_approval_reminder  = 6.hours

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


  ###############
  # Event hooks #
  ###############

  # Observer to echoable support action
  def supported(echoable, user)
    adjust_states(echoable, echoable.supporter_count.to_i-1)
  end

  # Observer to echoable unsupport action
  def unsupported(echoable, user)
    adjust_states(echoable, echoable.supporter_count.to_i+1)
  end

  # Observer to incorporable incorporated action
  def incorporated(incorporable, user)
    incorporate(incorporable, user)
    select_approved(incorporable)
  end


  #################
  # State machine #
  #################

  #
  # Reacts on echo/unecho event. I.e. when it's incorporable updates the sibling states, when drafteable,
  # adjust the readiness of the children.
  #
  def adjust_states(echoable, old_supporter_count)
    if echoable.incorporable?
      siblings = echoable.siblings
      update_incorporable_states(siblings, echoable, old_supporter_count)
    elsif echoable.draftable?
      children = echoable.sorted_children
      children.each do |child|
        adjust_readiness(child, false, false)
      end
    end
  end

  #
  # Calculate which incorporable's positions (ordered per supported_count) have changed, and update their states.
  #
  def update_incorporable_states(incorporables, changed_incorporable, old_supporter_count)
    # Get array order with id and supporter count
    old_order = incorporables.map{|s|[s.id, s.supporter_count.to_i]}

    # Set the old supporter count on the changed incorporable
    old_order[incorporables.index(changed_incorporable)][1] = old_supporter_count

    # Sort the array, thus getting the ordered array before the support/unsupport action
    old_order.sort!{|a, b| b[1] <=> a[1]}
    old_order.map!{|s|s[0]}
    incorporables.each_with_index do |incorporable, index|
      if index != old_order.index(incorporable.id) or incorporable.eql?(changed_incorporable)
        adjust_readiness(incorporable, index > old_order.index(incorporable.id), incorporable == changed_incorporable)
      end
    end
  end

  #
  # According to the given parameters, will either readify or track the incorporable.
  #
  def adjust_readiness(incorporable, position_decreased, changed_criteria)
    readiness = test_readiness(incorporable)
    if ((incorporable.tracked? and changed_criteria) or (!incorporable.tracked? and position_decreased)) and
        readiness
        readify(incorporable)
    elsif !incorporable.tracked? and changed_criteria and !readiness
      track(incorporable)
    end
  end

  #
  # Test if incorporable fulfills all conditions to become ready.
  #
  def test_readiness(incorporable)
    incorporable.supporter_count >= @@min_votes# and incorporable.quorum >= @@min_quorum
  end

  #
  # Set incorporable state to tracked.
  #
  def track(incorporable)
    set_track(incorporable)
  end

  #
  # Set incorporable state to ready.
  #
  def readify(incorporable)
    set_readify(incorporable)
    incorporable.reload
    Delayed::Job.enqueue TestForStagedJob.new(incorporable.id,incorporable.state_since), 1,
                         Time.now.advance(:seconds => @@time_ready)
  end

  #
  # Set incorporable state to staged.
  #
  def stage(incorporable)
    set_stage(incorporable)
    incorporable.reload
    select_approved(incorporable)
  end

  #
  # Select the suitable sibling from the incorporable to become approved.
  #
  def select_approved(incorporable)
    incorporable.reload
    if incorporable.parent.approved_children.empty?
      siblings = incorporable.siblings([incorporable.drafting_language.id]).select{|s|s.staged?}
      approve(siblings.first) if !siblings.empty?
    end
  end

  #
  # Set incorporable state to approved.
  #
  def approve(incorporable)
    set_approve(incorporable)
    incorporable.reload
    send_approved_email(incorporable)
    Delayed::Job.enqueue TestForPassedJob.new(incorporable.id), 1,
                         Time.now.advance(:seconds => @@time_approved)
  end

  #
  # Set incorporable state to incorporated.
  #
  def incorporate(incorporable, user)
    set_incorporate(incorporable)
    incorporable.reload
    send_incorporated_email(incorporable, user)
  end

  #
  # Removes all echos and puts the statement to tracked state.
  #
  def reset_incorporable(incorporable)
    EchoService.instance.reset_echoable(incorporable)
    incorporable.update_attribute(:times_passed, 0)
    set_track(incorporable)
  end


  #################
  # SENDING MAILS #
  #################

  #
  # Sends mails when the statement became approved.
  #
  def send_approved_email(incorporable)

    # Send the notification that the statement can be incorporated
    statement_document = incorporable.original_document
    if incorporable.times_passed == 0
      email = NotificationMailer.create_approval(incorporable, statement_document)
      NotificationMailer.deliver(email) if statement_document.author.drafting_notification == 1
    elsif incorporable.times_passed == 1
      supporters = incorporable.supporters.select{|supporter|
        supporter.speaks_language?(incorporable.original_language, 'intermediate') and
        supporter.drafting_notification == 1
      }
      email = NotificationMailer.create_supporters_approval(incorporable, statement_document, supporters)
      NotificationMailer.deliver(email)
    end

    # Send approval notification to the proposal supporters
    incorporable.reload
    supporters = incorporable.parent.supporters.select{|supporter|
      supporter.speaks_language?(incorporable.original_language) and
      supporter.drafting_notification == 1
    }
    email = ActivityTrackingMailer.create_approval_notification(incorporable, statement_document, supporters)
    ActivityTrackingMailer.deliver(email)

    # Schedule the reminder mail
    Delayed::Job.enqueue ApprovalReminderMailJob.new(incorporable.id, incorporable.state_since), 1,
                         Time.now + @@time_approval_reminder
  end

  #
  # Sends the approval reminder mail to the author of the incorporable.
  #
  def send_approval_reminder(incorporable)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_approval_reminder(incorporable, statement_document)
    NotificationMailer.deliver(email) if statement_document.author.drafting_notification == 1
  end

  #
  # Sends the approval reminder mail to all supporters of the incorporable.
  #
  def send_supporters_approval_reminder(incorporable)
    statement_document = incorporable.original_document
    supporters = incorporable.supporters.select{|supporter|
      supporter.speaks_language?(incorporable.original_language, 'intermediate') and
      supporter.drafting_notification == 1
    }
    email = NotificationMailer.create_supporters_approval_reminder(incorporable, statement_document, supporters)
    NotificationMailer.deliver(email)
  end

  #
  # Sends mail to notify the author that he has passed the opportunity to incorporate his statement.
  #
  def send_passed_email(incorporable)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_passed(statement_document)
    NotificationMailer.deliver(email) if statement_document.author.drafting_notification == 1
  end

  #
  # Sends mail to notify all supporters of the statement that they have passed the opportunity to incorporate it.
  #
  def send_supporters_passed_email(incorporable)
    statement_document = incorporable.original_document
    supporters = incorporable.supporters.select{|supporter|
      supporter.speaks_language?(incorporable.original_language, 'intermediate') and
      supporter.drafting_notification == 1
    }
    email = NotificationMailer.create_supporters_passed(statement_document, supporters)
    NotificationMailer.deliver(email)
  end

  #
  # Sends mail author that he has passed the opportunity to incorporate his statement.
  #
  def send_incorporated_email(incorporable, user)
    statement_document = incorporable.original_document
    email = NotificationMailer.create_incorporated(incorporable, statement_document)
    NotificationMailer.deliver(email) if statement_document.author.drafting_notification == 1
  end


  private

  #
  # Sets and persists the given state and the state_since timestamp.
  #
  %w(track readify stage approve incorporate).each do |transition|
    class_eval %(
      def set_#{transition}(incorporable)
        incorporable.state_since = Time.now
        incorporable.send('#{transition}!')
        incorporable.save
      end
    )
  end
end