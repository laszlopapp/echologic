require 'singleton'

class ActivityTrackingService
  include Singleton

  attr_accessor :period, :charges

  def initialize
  end

  def update(*args)
    send(*args)
  end


  #########
  # Hooks #
  #########

  def supported(echoable, user)
    return if user.nil?
    subscription = echoable.subscriptions.find_by_subscriber_id(user.id) ||
                     Subscription.new(:subscriber => user, :subscriber_type => user.class.name,
                                      :subscribeable => echoable, :subscribeable_type => echoable.class.name)
    echoable.subscriptions << subscription if subscription.new_record?
    # When echoable is a proposal, then we must follow the main question too
    # When echoable is an improvement/pro-contra, then we must follow the parent proposal too
    if !echoable.parent.nil?
      parent_subscription = echoable.parent.subscriptions.find_by_subscriber_id(user.id) ||
                       Subscription.new(:subscriber => user, :subscriber_type => user.class.name,
                                        :subscribeable => echoable.parent, :subscribeable_type => echoable.parent.class.name)
      user.subscriptions << parent_subscription if parent_subscription.new_record?
    end
  end

  def unsupported(echoable, user)
    return if user.nil?
    subscription = echoable.subscriptions.find_by_subscriber_id(user.id)
    echoable.subscriptions.delete(subscription) if subscription
    # When a proposal, then we must remove the question subscription in the case when no more sibling is around
    # When an improvement/pro-contra, then we must remove the proposal subscription in the case when no more sibling is around
    if !echoable.parent.nil?
      parent_subscription = user.subscriptions.find_by_subscribeable_id(echoable.parent_id)
      if (user.subscriptions.map(&:subscribeable_id) & echoable.parent.child_statements.map(&:id)).empty?
        user.subscriptions.delete(parent_subscription) if parent_subscription
      end
    end
  end

  def created(node)
    published(node) if node.published?
  end

  def published(node)
    created_event(node)
  end

  def incorporated(echoable, user)
  end


  #################
  # Service logic #
  #################

  #
  # Creates an event for the newly created subscribeable object
  #
  def created_event(node)

    event_json = {
      :type => node.class.name.underscore,
      :id => node.target_id,
      :level => node.class.is_top_statement? ? node.parent.level + 1 : node.level,
      :tags => node.filtered_topic_tags,
      :documents => set_titles_hash(node.statement_documents),
      :parent_documents => node.parent ? set_titles_hash(node.parent.statement_documents) : nil,
      :parent_id => node.parent_id || -1,
      :operation => 'created'
    }.to_json

    Event.create(:event => event_json,
                 :operation => node.parent.nil? ? "new" : "new_child",
                 :subscribeable_type => node.class.name,
                 :subscribeable => node.parent)
  end

  #
  # Manages the counter to calculate current charge and schedules the next job with it.
  #
  def enqueue_activity_tracking_job(current_job_id = 0)

    # After restarting the process (on new deployment) the
    # counter is initialized with the current job id.
    job_id = current_job_id + 1

    # Enqueuing the next job
    Delayed::Job.enqueue ActivityTrackingJob.new(job_id, job_id % @charges), 0,
                         Time.now.utc.advance(:seconds => @period/@charges)
  end

  #
  # Actually executes the job, generates activity mails, sends them and schedules the next job.
  #
  def generate_activity_mails(current_job_id, current_charge)

    # Enqueuing the next job
    enqueue_activity_tracking_job(current_job_id)

    # Calculating 'after time' to minimize timeframe errors due to long lasting processes
    # FIXME: correct solution should be to persist the last_notification time per user
    after_time = @period.ago.utc - 5.minutes  # with 5 minutes safety buffer (some events might be delivered twice)

    # Iterating over users in the current charge
    User.all(:conditions => ["(id % ?) = ? and activity_notification = 1", @charges, current_charge]).each do |recipient|

      # Collecting events
      events = Event.find_tracked_events(recipient, after_time).map{|e|JSON.parse(e.event)}
      # Filter only events whose titles languages the recipient speaks
      events = events.select{|e| !(e['documents'].keys.map{|id|id.to_i} & recipient.sorted_spoken_languages).empty? }

      next if events.blank? #if there are no events to send per email, take the next user

      # take the question events apart
      root_events = events.select{|e|e['level'] == 0}
      events -= root_events

      # created an Hash containing the number of ocurrences of the new tags in the new questions
      tag_counts = root_events.each_with_object({}) do |root, tags_hash|
        root['tags'].each{|tag| tags_hash[tag] = tags_hash.has_key?(tag) ? tags_hash[tag] + 1 : 1 }
      end

      #turn array of events into an hash
      events = events.each_with_object({}) do |e, hash|
        hash[e['level']] ||= {}
        hash[e['level']][e['parent_id']] ||= {}
        hash[e['level']][e['parent_id']][e['type']] ||= {}
        hash[e['level']][e['parent_id']][e['type']][e['operation']] ||= []
        hash[e['level']][e['parent_id']][e['type']][e['operation']] << e
      end

      # Sending the mail
      send_activity_email(recipient, root_events, tag_counts, events)
    end
  end

  #
  # Sends an activity tracking E-Mail to the given recipient.
  #
  def send_activity_email(recipient, root_events, question_tags, events)
    puts "Send mail to:" + recipient.email
    mail = ActivityTrackingMailer.create_activity_tracking_mail(recipient,root_events,question_tags,events)
    ActivityTrackingMailer.deliver(mail)
  end

  #handle_asynchronously :send_activity_email



  def set_titles_hash(documents)
    documents.each_with_object({}) do |document, titles_hash|
      titles_hash[document.language_id] = document.title
    end
  end
end