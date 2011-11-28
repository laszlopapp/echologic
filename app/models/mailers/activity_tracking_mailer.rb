class ActivityTrackingMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send the activities on the subscribed objects to the subscribable
  def activity_tracking_mail(recipient, root_events, question_tag_counts, events)
    language = recipient.default_language
    subject       I18n.t('mailers.activity_tracking.subject', :locale => language.code)
    from          "content@echo.to"
    recipients    recipient.email
    sent_on       Time.now
    content_type "text/html"
    body          :name => recipient.full_name,
                  :root_events => root_events,
                  :question_tag_counts => question_tag_counts,
                  :events => events,
                  :language => language,
                  :preferred_language_ids => recipient.sorted_spoken_languages
  end

end