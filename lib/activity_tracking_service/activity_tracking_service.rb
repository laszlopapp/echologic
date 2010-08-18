require 'singleton'


class ActivityTrackingService
  include Singleton

  attr_accessor :period, :charges, :counter

  def initialize
    @counter = -1
  end

  def update(*args)
    send(*args)
  end


  #########
  # Hooks #
  #########

  def supported(echoable, user)
    echoable.add_subscriber(user)
  end

  def unsupported(echoable, user)
    echoable.remove_subscriber(user)
  end

  def incorporated(echoable, user)
  end


  #################
  # Service logic #
  #################

  #
  # Sends an activity tracking E-Mail to the given recipient.
  #
  def send_activity_tracking_email(recipient, question_events, question_tags, events)
    mail = ActivityTrackingMailer.create_activity_tracking_email(recipient, question_events, question_tags, events)
    ActivityTrackingMailer.deliver(mail)
  end

  #handle_asynchronously :send_activity_tracking_email


  #
  # Manages the counter to calculate current charge and schedules the next job with it.
  #
  def enqueue_next_activity_tracking_job(current_charge = 0)
    if @counter == -1
      @counter = current_charge
    end
    @counter += 1
    Delayed::Job.enqueue ActivityTrackingJob.new(@counter%@charges, @charges, @period), 0,
                         current_time.advance(:seconds => @period/@charges)
  end
end