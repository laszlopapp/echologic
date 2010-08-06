class NotificationMailer < ActionMailer::Base
  
  def approval(statement, statement_document)
    subject       I18n.t('notification_mails.approval.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title, 
                  :url => url_for(statement), :language => statement_document.language.code
  end
  
  def supporter_approval(statement, statement_document, user)
    subject       I18n.t('notification_mails.supporter_approval.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.full_name, :title => statement_document.title,
                  :url => url_for(statement), :language => statement_document.language.code
  end
  
  def approval_reminder(statement, statement_document, user=nil)
    subject       I18n.t('notification_mails.approval_reminder.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    user.email || statement_document.author.email
    sent_on       Time.now
    body          :name => user.full_name || statement_document.author.full_name, :title => statement_document.title, 
                  :url => url_for(statement), :language => statement_document.language.code
  end
  
  def passed(statement_document, user=nil)
    subject       I18n.t('notification_mails.passed.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    user.email || statement_document.author.email
    sent_on       Time.now
    body          :name => user.full_name || statement_document.author.full_name, :title => statement_document.title,
                  :language => statement_document.language.code
  end
  
  def incorporated(statement, statement_document)
    subject       I18n.t('notification_mails.incorporated.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :url => url_for(statement), :language => statement_document.language.code
  end
end
