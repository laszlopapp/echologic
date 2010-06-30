#job class responsible for getting all user related events and sending an email 
class ActivityTrackingNotification
  
  def initialize
  end

  def perform
    week_day = Time.now.wday
    User.all(:conditions => ["(id % 7) = ?", week_day]).each do |user|
      next if !user.email_notification?
      events = Event.find_by_sql(sanitize_sql(["SELECT * from events e 
                                               LEFT JOIN statement_nodes s ON s.id = e.subscribeable_id
                                               where and s.creator_id != ?
                                               and (s.parent_id = NULL or s.root_id IN (?))
                                               and e.created_at > ?
                                               order_by type DESC 
                                               created_at DESC",user.id,user.subscribeables.map{|s|s.id},7.days.ago]))
                 
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
      
      user.deliver_activity_tracking_email!(question_events, tags, events - question_events)
    end
    Delayed::Job.enqueue ActivityTrackingNotification.new, 0, Time.now.tomorrow.midnight
  end
end
