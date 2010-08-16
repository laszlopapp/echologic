class DraftingMailer < ActionMailer::Base
  include StatementHelper
  def approval(statement, statement_document)
    subject       I18n.t('notification_mailer.approval.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :link => proposal_path(statement.parent), :language => statement_document.language
  end

  def supporters_approval(statement, statement_document, users)
    subject       I18n.t('notification_mailer.supporters_approval.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    bcc           users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => improvement_proposal_path(statement),
                  :language => statement_document.language
  end

  def approval_reminder(statement, statement_document)
    subject       I18n.t('notification_mailer.approval_reminder.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :link => proposal_path(statement.parent), :language => statement_document.language
  end

  def supporters_approval_reminder(statement, statement_document, users)
    subject       I18n.t('notification_mailer.supporters_approval_reminder.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    bcc           users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => proposal_path(statement.parent),
                  :language => statement_document.language, :p_title => statement.parent.original_document.title
  end

  def passed(statement_document)
    subject       I18n.t('notification_mailer.passed.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :language => statement_document.language
  end

  def supporters_passed(statement_document, users)
    subject       I18n.t('notification_mailer.supporters_passed.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    bcc           users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :language => statement_document.language
  end

  def incorporated(statement, statement_document)
    subject       I18n.t('notification_mailer.incorporated.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    recipients    statement_document.author.email
    sent_on       Time.now
    body          :name => statement_document.author.full_name, :title => statement_document.title,
                  :link => proposal_path(statement.parent), :language => statement_document.language
  end

  def approval_notification(statement, statement_document, users)
    subject       I18n.t('notification_mailer.approval_notification.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    bcc           users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => improvement_proposal_path(statement),
                  :language => statement_document.language
  end


  def incorporation_notification(statement, statement_document, users)
    subject       I18n.t('notification_mailer.incorporation_notification.subject', :locale => statement_document.language.code)
    from          "noreply@echologic.org"
    bcc           users.map{|u|u.email}
    sent_on       Time.now
    body          :title => statement_document.title, :link => proposal_path(statement),
                  :language => statement_document.language
  end

end
