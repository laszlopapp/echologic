require 'singleton'


class ActivityTrackingService
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
  end

  def enqueue_activity_tracking_job
    current_time = Time.now.utc
    Delayed::Job.enqueue ActivityTrackingJob.new(@counter%@charges, @charges, current_time),
                         0,
                         current_time.advance(:seconds => @period/@charges)
  end
end