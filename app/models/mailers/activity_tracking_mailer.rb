class ActivityTrackingMailer < ActionMailer::Base
  # Send the activities on the subscribed objects to the subscribeable
  def activity_tracking_email(subscriber,question_events, question_tags, events)
    default = subscriber.default_language
    subject       I18n.t('mail.activity_tracking.subject', :locale => default.code)
    from          "noreply@echologic.org"
    recipients    subscriber.email
    sent_on       Time.now
    content_type "text/html"
    body          :question_events => question_events,
                  :question_tags => question_tags,
                  :events => events,
                  :language => default
  end
  
end