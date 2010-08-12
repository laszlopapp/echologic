#job class responsible for getting all user related events and sending an email
class ActivityTrackingJob < Struct.new(:current_charge, :charges, :tracking_period)
  
  def perform
    puts "Starting"
    User.all(:conditions => ["(id % ?) = ?", @charges, @current_charge]).each do |user|

      next if !user.email_notification?
      puts user.full_name
      events = Event.find_tracked_events(user, Time.now.utc.since(-@tracking_period))
      next if events.blank? #if there are no events to send per email, then get the hell out
      puts "Has events"
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
      puts "send mail"
      user.deliver_activity_tracking_email!(question_events, tags, events - question_events)
    end
    puts "enqueue"
    ActivityNotificationService.instance.enqueue_activity_tracking_job
  end
end
