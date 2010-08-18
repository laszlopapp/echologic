#
# Job responsible for getting all user related events, sending mails and scheduling the next job.
#
class ActivityTrackingJob < Struct.new(:current_charge, :charges, :period)

  def perform

    # Enqueuing the next job
    ActivityTrackingService.instance.enqueue_next_activity_tracking_job(current_charge)

    # Calculating 'after time' to minimize timeframe errors due to long lasting processes
    # FIXME: correct solution should be to persist the last_notification time per user
    after_time = period.ago.utc - 5.minutes  # with 5 minutes safety buffer (some events might be delivered twice)

    # Iterating over users in the current charge
    User.all(:conditions => ["(id % ?) = ? and activity_notification = 1", charges, current_charge]).each do |recipient|

      # Collecting events
      events = Event.find_tracked_events(recipient, after_time)
      next if events.blank? #if there are no events to send per email, then get the hell out
      question_events = events.select{|e|JSON.parse(e.event).keys[0] == 'question'}
      tags = Hash.new
      question_events.each do |question|
        question_data = JSON.parse(question.event)
        question_data['question']['tao_tags'].each do |tao_tag|
          tags[tao_tag['tag']['value']] = tags[tao_tag['tag']['value']] ? tags[tao_tag['tag']['value']] + 1 : 1
        end
      end
      events.sort! do |a,b|
        a_parsed = JSON.parse(a.event)
        root_x = a_parsed[a_parsed.keys[0]]['root_id'] || -1
        parent_x = a_parsed[a_parsed.keys[0]]['parent_id'] || -1
        b_parsed = JSON.parse(b.event)
        root_y = b_parsed[b_parsed.keys[0]]['root_id'] || -1
        parent_y = b_parsed[b_parsed.keys[0]]['parent_id'] || -1
        [root_x,parent_x] <=> [root_y,parent_y]
      end

      # Sending the mail
      ActivityTrackingService.instance.send_activity_tracking_email(recipient,
                                                                    question_events,
                                                                    tags,
                                                                    events - question_events)
    end
  end
end
