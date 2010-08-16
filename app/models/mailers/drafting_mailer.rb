class DraftingMailer < ActionMailer::Base
  include StatementHelper
  def approval(incorporable, approved_document)
    subject       I18n.t('notification_mailer.approval.subject',
                         :locale => approved_document.language.code)
    from          "noreply@echologic.org"
    recipients    approved_document.author.email
    sent_on       Time.now
    body          :name => approved_document.author.full_name,
                  :title => approved_document.title,
                  :link => proposal_path(incorporable.parent),
                  :language => approved_document.language
  end

  def supporters_approval(incorporable, approved_document, recipients)
    subject       I18n.t('notification_mailer.supporters_approval.subject',
                         :locale => approved_document.language.code)
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :title => approved_document.title,
                  :link => improvement_proposal_path(incorporable),
                  :language => approved_document.language
  end

  def approval_notification(incorporable, approved_document, recipients)
    subject       I18n.t('notification_mailer.approval_notification.subject',
                         :locale => approved_document.language.code)
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :title => approved_document.title,
                  :link => improvement_proposal_path(incorporable),
                  :language => approved_document.language
  end

  def approval_reminder(incorporable, approved_document)
    subject       I18n.t('notification_mailer.approval_reminder.subject',
                         :locale => approved_document.language.code)
    from          "noreply@echologic.org"
    recipients    approved_document.author.email
    sent_on       Time.now
    body          :name => approved_document.author.full_name,
                  :title => approved_document.title,
                  :link => proposal_path(incorporable.parent),
                  :language => approved_document.language
  end

  def supporters_approval_reminder(incorporable, approved_document, recipients)
    subject       I18n.t('notification_mailer.supporters_approval_reminder.subject',
                         :locale => approved_document.language.code)
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :title => approved_document.title,
                  :link => proposal_path(incorporable.parent),
                  :language => approved_document.language,
                  :p_title => incorporable.parent.document_in_original_language.title
  end

  def passed(passed_document)
    subject       I18n.t('notification_mailer.passed.subject',
                         :locale => passed_document.language.code)
    from          "noreply@echologic.org"
    recipients    passed_document.author.email
    sent_on       Time.now
    body          :name => passed_document.author.full_name,
                  :title => passed_document.title,
                  :language => passed_document.language
  end

  def supporters_passed(passed_document, recipients)
    subject       I18n.t('notification_mailer.supporters_passed.subject',
                         :locale => passed_document.language.code)
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :title => passed_document.title,
                  :language => passed_document.language
  end

  def incorporated(incorporable, incorporated_document)
    subject       I18n.t('notification_mailer.incorporated.subject',
                         :locale => incorporated_document.language.code)
    from          "noreply@echologic.org"
    recipients    incorporated_document.author.email
    sent_on       Time.now
    body          :name => incorporated_document.author.full_name,
                  :title => incorporated_document.title,
                  :link => proposal_path(incorporable.parent),
                  :language => incorporated_document.language
  end

  def incorporation_notification(incorporable, incorporated_document, recipients)
    subject       I18n.t('notification_mailer.incorporation_notification.subject',
                         :locale => incorporated_document.language.code)
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :title => incorporated_document.title,
                  :link => proposal_path(incorporable.parent),
                  :language => incorporated_document.language
  end

end
