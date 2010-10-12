#
# Job responsible for getting all user related events, sending mails and scheduling the next job.
#
class ActivityTrackingJob < Struct.new(:job_id, :current_charge)

  def perform
    begin
      ActivityTrackingService.instance.generate_activity_mails(job_id, current_charge)
    rescue Exception => e
      puts "Error"
      puts e.backtrace
    else
      puts "ok"
    end
  end
end
