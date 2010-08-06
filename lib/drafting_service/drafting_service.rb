require 'singleton'

class DraftingService
  
  include Singleton

  @@min_quorum = 50
  @@min_votes  = 5
  @@time_ready  = Time.now.advance(:hours => 10)
  @@time_approved  = Time.now.advance(:hours => 10)
  @@time_approval_reminder  = Time.now.advance(:hours => 6)

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
    draft(echoable, echoable.supporter_count-1)
  end
  
  # observer to echoable unsupport action
  def unsupported(echoable, user)
    draft(echoable, echoable.supporter_count+1)
  end
  
  # observer to echoable incorporated action
  def incorporated(echoable)
    incorporate(echoable)
    select_approved(echoable)
  end
  
  def stage(statement)
    set_stage(statement)
    select_approved(statement)
  end
  
  # select a suitable sibling from the statement to become approved
  def select_approved(statement)
    if statement.parent.approved_children.empty?
      siblings = statement.siblings.select{|s|s.staged?}
      approve(siblings.first) if !siblings.empty?
    end
  end
  
  def send_approved_email(statement)
    statement_document = statement.original_document
    if statement.times_passed == 0
      email = NotificationMailer.create_approval(statement, statement_document)
      NotificationMailer.deliver(email)
    else 
      statement.supporters.select{|sup|sup.languages('advanced').include?(statement.original_language)}.each do |supporter|
        email = NotificationMailer.create_supporter_approval(statement, statement_document, supporter)
        NotificationMailer.deliver(email)
      end
    end
  end
  
  def send_approval_reminder(statement)
    statement_document = statement.original_document
    if statement.times_passed == 0
      email = NotificationMailer.create_approval_reminder(statement, statement_document)
      NotificationMailer.deliver(email)
    else 
      statement.supporters.select{|sup|sup.languages('advanced').include?(statement.original_language)}.each do |supporter|
        email = NotificationMailer.create_approval_reminder(statement, statement_document, supporter)
        NotificationMailer.deliver(email)
      end
    end
  end
  
  def send_passed_email(statement)
    statement_document = statement.original_document
    email = NotificationMailer.create_passed(statement_document)
    NotificationMailer.deliver(email)
  end
  
  def send_supporters_passed_email(statement)
    statement_document = statement.original_document
    statement.supporters.select{|sup|sup.languages('advanced').include?(statement.original_language)}.each do |supporter|
      email = NotificationMailer.create_approval_reminder(statement_document, supporter)
      NotificationMailer.deliver(email)
    end
  end
  
  def send_incorporated_email(statement)
    statement_document = statement.original_document
    email = NotificationMailer.create_incorporated(statement, statement_document, supporter)
    NotificationMailer.deliver(email)
  end
  
  private
  
  # kickstarts the drafting process, i e when it's incorporable updates the sibling states, when drafteable, 
  # adjust the readiness of the children
  def draft(echoable, old_supporter_count)
    if echoable.incorporable?
      siblings = echoable.siblings
      update_statement_states(siblings, echoable, old_supporter_count)
    elsif echoable.drafteable?
      children = echoable.sorted_children
      children.each do |child|
        adjust_readiness(child, false, false)
      end
    end
  end
  
  # calculate which statement's positions (ordered per supported_count) have changed, and update their states
  def update_statement_states(statements, changed_statement, old_supporter_count)
    old_order = statements.map{|s|[s.id, s.supporter_count]} # get array order with id and supporter count
    old_order[statements.index(changed_statement)][1] = old_supporter_count # set the old supporter count on the changed statement
    old_order.sort!{|a, b| b[1] <=> a[1]} #sort the array, thus getting the ordered array before the support/unsupport action)
    old_order.map!{|s|s[0]}
    
    statements.each_with_index do |statement, index|
      if index != old_order.index(statement.id)
        adjust_for_readiness(statement, index > old_order.index(statement.id), statement == changed_statement)
      end
    end
  end
  
  # according to the given parameters, will either readify or track the statement 
  def adjust_readiness(statement, position_decreased, changed_criteria)
    if (statement.tracked? and changed_criteria and test_readiness(statement)) or 
       (!statement.tracked? and position_decreased)
      readify(statement) 
    elsif !statement.tracked? and changed_criteria and !test_readiness(statement)
      track(statement)
    end
  end
  
  # test if statement fulfills all conditions to become ready
  def test_readiness(statement)
    statement.supporter_count >= @@min_votes and statement.quorum >= @@min_quorum
  end
  
  # set statement state as tracked
  def track(statement)
    set_track(statement)
  end
  
  # set statement as ready
  def readify(statement)
    set_readify(statement)
    Delayed::Job.enqueue TestForStaged.new(statement.id,statement.state_since), 1, @@time_ready
  end
  
  # set statement as approved
  def approve(statement)
    set_approved(statement)
    send_approved_email(statement)
    Delayed::Job.enqueue TestForPassed.new(statement.id,statement.state_since), 1, @@time_approved
    Delayed::Job.enqueue ApprovalReminder.new(statement.id), 1, @@time_approval_reminder
  end
  
  def incorporate(statement)
    set_incorporate(statement)
    send_incorporated_email(statement)
  end
  
  def reset_statement(statement)
    statement.user_echos.destroy
    statement.times_passed = 0
    set_track(statement)
  end
  
  %w(track readify stage approve incorporate).each do |transition|
    class_eval %(
      def set_#{transition}
        statement.state_since=Time.now
        statement.send(#{transition}!)
      end
    )
  end
end