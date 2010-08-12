require 'singleton'


class ActivityNotificationService
  include Singleton

  attr_accessor :period, :charges, :counter

  def initialize
    @counter = 0
  end

  def update(*args)
    send(*args)
  end

  def supported(echoable, user)
    echoable.add_subscriber(user)
  end

  def unsupported(echoable, user)
    echoable.remove_subscriber(user)
  end

  def incorporated(echoable, user)
    statement_document = echoable.original_document
    supporters = echoable.parent.supporters
    email = ActivityTrackingMailer.create_incorporation_notification(echoable, statement_document, supporters)
    ActivityTrackingMailer.deliver(email)
  end

  def enqueue_activity_tracking_job
    current_time = Time.now
    Delayed::Job.enqueue ActivityTrackingJob.new(@counter%@charges, @charges, current_time), 
                         0, 
                         current_time.advance(:seconds => @period/@charges)
  end
end