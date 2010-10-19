class ActivityTrackingMailer < ActionMailer::Base
  # Send the activities on the subscribed objects to the subscribable
  def activity_tracking_email(recipient,question_events, question_tags, events)
    default = recipient.default_language
    subject       I18n.t('mailers.activity_tracking.subject', :locale => default.code)
    from          "noreply@echologic.org"
    recipients    recipient.email
    sent_on       Time.now
    content_type "text/html"
    body          :question_events => question_events,
                  :question_tags => question_tags,
                  :events => events,
                  :language => default,
                  :preferred_language_ids => recipient.sorted_spoken_language_ids
  end

end