require 'singleton'

class DraftingService

  include Singleton

  ##############
  # Parameters #
  ##############

  @@min_quorum = 50
  @@min_votes  = 3
  @@time_ready  = 24.hours
  @@time_approved  = 24.hours
  @@time_approval_reminder  = 12.hours

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


  # Derived time parameters for mailing

  def self.approved_hours
    @@time_approved.to_i / 3600
  end

  def self.approved_hours_left
    (@@time_approved - @@time_approval_reminder).to_i / 3600
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
    incorporable.reload
    incorporate(incorporable)
    select_approved(incorporable)
  end


  #################
  # State machine #
  #################

  #
  # Reacts on echo/unecho event. I.e. when it's incorporable updates the sibling states, when draftable,
  # adjust the readiness of the children.
  #
  def adjust_states(echoable, old_supporter_count)
    if echoable.incorporable?
      siblings = echoable.sibling_statements
      update_incorporable_states(siblings, echoable, old_supporter_count)
    elsif echoable.draftable?
      children = echoable.children_statements
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
                         Time.now.advance(:seconds => @@time_ready).utc
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
      siblings = incorporable.sibling_statements([incorporable.drafting_language.id]).select{|s|s.staged?}
      approve(siblings.first) if !siblings.empty?
    end
  end

  #
  # Set incorporable state to approved.
  #
  def approve(incorporable)
    set_approve(incorporable)
    incorporable.reload
    send_approval_mails(incorporable)
    Delayed::Job.enqueue TestForPassedJob.new(incorporable.id), 1,
                         Time.now.advance(:seconds => @@time_approved).utc
  end

  #
  # Sends the reminder mails to the appropriate recipients.
  #
  def remind(incorporable)
    # First round
    if incorporable.times_passed == 0
      send_approval_reminder_mail(incorporable)

    # Second round
    elsif incorporable.times_passed == 1
      send_supporters_approval_reminder_mail(incorporable)
    end
  end

  #
  # Set incorporable state to incorporated.
  #
  def incorporate(incorporable)
    set_incorporate(incorporable)
    incorporable.reload
    send_incorporation_mails(incorporable)
  end

  #
  # Called if the user(s) passed to incorporate the statement.
  #
  def pass(incorporable)
    begin
      StatementNode.transaction do
        incorporable.times_passed += 1
        incorporable.drafting_info.save
        incorporable.reload

        # First round
        if incorporable.times_passed == 1
          DraftingService.instance.send_passed_mail(incorporable)
          DraftingService.instance.stage(incorporable)

        # Second round
        elsif incorporable.times_passed == 2
          DraftingService.instance.send_supporters_passed_mail(incorporable)
          DraftingService.instance.reset(incorporable)
          DraftingService.instance.select_approved(incorporable)
        end
      end
    rescue StandardError => error
      puts "Error passing IP '#{incorporable.id}':" + error.backtrace
    end
  end


  #
  # Removes all echos and sends the statement back to tracked state.
  #
  def reset(incorporable)
    withdraw_echos(incorporable)
    incorporable.times_passed = 0
    incorporable.drafting_info.save
    incorporable.reload
    set_track(incorporable)
  end


  #################
  # SENDING MAILS #
  #################

  #
  # Sends mails when the statement became approved.
  #
  def send_approval_mails(incorporable)
    incorporable.reload
    mail_data = assembly_mail_data(incorporable)

    # Send notification that the statement can be incorporated
    ip_recipients = []
    approved_document = incorporable.document_in_original_language
    if incorporable.times_passed == 0 && approved_document.author.drafting_notification == 1
      ip_recipients << approved_document.author
      email = DraftingMailer.create_approval(mail_data)
      DraftingMailer.deliver(email)
    elsif incorporable.times_passed == 1
      ip_recipients = notified_supporters(incorporable)
      if !ip_recipients.blank?
        email = DraftingMailer.create_supporters_approval(ip_recipients, mail_data)
        DraftingMailer.deliver(email)
      end
    end

    # Send approval notification to the rest of the supporters of the proposal
    p_recipients = notified_supporters(incorporable.parent) - ip_recipients
    if !p_recipients.blank?
      email = DraftingMailer.create_approval_notification(p_recipients, mail_data)
      DraftingMailer.deliver(email)
    end

    # Schedule job to send reminder mails
    Delayed::Job.enqueue ApprovalReminderMailJob.new(incorporable.id, incorporable.state_since), 1,
                         Time.now.advance(:seconds => @@time_approval_reminder)
  end

  #
  # Sends the approval reminder mail to the author of the incorporable.
  #
  def send_approval_reminder_mail(incorporable)
    approved_document = incorporable.document_in_original_language
    if approved_document.author.drafting_notification == 1
      email = DraftingMailer.create_approval_reminder(assembly_mail_data(incorporable))
      DraftingMailer.deliver(email)
    end
  end

  #
  # Sends the approval reminder mail to all supporters of the incorporable.
  #
  def send_supporters_approval_reminder_mail(incorporable)
    recipients = notified_supporters(incorporable)
    if !recipients.blank?
      email = DraftingMailer.create_supporters_approval_reminder(recipients, assembly_mail_data(incorporable))
      DraftingMailer.deliver(email)
    end
  end

  #
  # Sends mail to notify the author that he has passed the opportunity to incorporate his statement.
  #
  def send_passed_mail(incorporable)
    passed_document = incorporable.document_in_original_language
    if passed_document.author.drafting_notification == 1
      email = DraftingMailer.create_passed(assembly_mail_data(incorporable))
      DraftingMailer.deliver(email)
    end
  end

  #
  # Sends mail to notify all supporters of the statement that they have passed the opportunity to incorporate it.
  #
  def send_supporters_passed_mail(incorporable)
    recipients = notified_supporters(incorporable)
    if !recipients.blank?
      email = DraftingMailer.create_supporters_passed(recipients, assembly_mail_data(incorporable))
      DraftingMailer.deliver(email)
    end
  end

  #
  # Sends mail author that he has passed the opportunity to incorporate his statement.
  #
  def send_incorporation_mails(incorporable)
    mail_data = assembly_mail_data(incorporable)

    # Thank you mail to the author
    ip_recipient = []
    draftable_document = incorporable.parent.document_in_original_language
    if draftable_document.author.drafting_notification == 1
      ip_recipient << draftable_document.author
      email = DraftingMailer.create_incorporated(mail_data)
      DraftingMailer.deliver(email)
    end

    # Notification mail to the rest of the supporters of the proposal
    p_recipients = notified_supporters(incorporable.parent, false) - ip_recipient
    if !p_recipients.blank?
      email = DraftingMailer.create_incorporation_notification(p_recipients, mail_data)
      DraftingMailer.deliver(email)
    end
  end


  private

  #
  # Returns a map with data used to create the mail bodies.
  #
  def assembly_mail_data(incorporable)
    {
      :incorporable => incorporable,
      :draftable => incorporable.parent,
      :incorporable_document => incorporable.document_in_original_language,
      :draftable_document => incorporable.parent.document_in_original_language,
      :language => incorporable.drafting_language.code
    }
  end

  #
  # Returns those supporters of the echoable who would like to receive drafting notifications.
  #
  def notified_supporters(echoable, check_language_skills = true)
    echoable.reload
    echoable.supporters.select{|supporter|
      supporter.drafting_notification == 1 &&
      (!check_language_skills || supporter.speaks_language?(echoable.original_language, 'intermediate'))
    }
  end

  #
  # Withdraws all echos from the given echoable.
  #
  def withdraw_echos(echoable)
    echoable.user_echos.supported.all.each{|ue|
      ue.supported = false
      ue.save
    }
    echoable.reload
    echoable.echo.update_counter!
    echoable.echo.save
    echoable.save
  end

  #
  # Sets and persists the given state and the state_since timestamp.
  #
  %w(track readify stage approve incorporate).each do |transition|
    class_eval %(
      def set_#{transition}(incorporable)
        incorporable.state_since = Time.now.utc
        incorporable.drafting_info.save
        incorporable.send('#{transition}!')
        incorporable.save
      end
    )
  end
end