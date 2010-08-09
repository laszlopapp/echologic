class ActivityTrackingMailer < ActionMailer::Base
  include StatementHelper
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
  
  def approval_notification(statement, statement_document, users)
    subject       I18n.t('notification_mailer.approval_notification.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => improvement_proposal_path(statement), 
                  :language => statement_document.language
  end
  
  
  def incorporation_notification(statement, statement_document, users)
    subject       I18n.t('notification_mailer.incorporation_notification.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => proposal_path(statement), 
                  :language => statement_document.language
  end
  
end