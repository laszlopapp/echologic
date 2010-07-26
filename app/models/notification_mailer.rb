class NotificationMailer < ActionMailer::Base
  
  def approval(statement_document)
    subject       I18n.t('notification_mails.approval.subject')
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title, 
                  :url => approval_url(statement_document)
  end
  
  def approval_reminder(statement_document)
    subject       I18n.t('notification_mails.approval_reminder.subject')
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title, 
                  :url => approval_url(statement_document)
  end
  
  def expiration(statement_document)
    subject       I18n.t('notification_mails.expiration.subject')
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title
  end
  
  def approval_repeat(statement_document)
    subject       I18n.t('notification_mails.approval_repeat.subject')
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :url => approval_url(statement_document)
  end
end
