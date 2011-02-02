class ActivityTrackingMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send the activities on the subscribed objects to the subscribable
  def activity_tracking_mail(recipient, root_events, tags, events)
    language = recipient.default_language
    subject       I18n.t('mailers.activity_tracking.subject', :locale => language.code)
    from          "noreply@echologic.org"
    recipients    recipient.email
    sent_on       Time.now
    content_type "text/html"
    body          :name => recipient.full_name,
                  :root_events => root_events,
                  :tags => tags,
                  :events => events,
                  :language => language,
                  :preferred_language_ids => recipient.sorted_spoken_language_ids
  end

end