require 'drafting_service'

class DraftingMailer < ActionMailer::Base
  def approval(mail_data)
    subject       I18n.t('mailers.drafting.approval.subject')
    from          "drafting@echo.to"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title.strip,
                  :hours => DraftingService.approved_hours,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def supporters_approval(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_approval.subject')
    from          "drafting@echo.to"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :hours => DraftingService.approved_hours,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def approval_notification(recipients, mail_data)
    subject       I18n.t('mailers.drafting.approval_notification.subject')
    from          "drafting@echo.to"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def approval_reminder(mail_data)
    subject       I18n.t('mailers.drafting.approval_reminder.subject')
    from          "drafting@echo.to"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :hours => DraftingService.approved_hours_left,
                  :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def supporters_approval_reminder(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_approval_reminder.subject')
    from          "drafting@echo.to"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :hours => DraftingService.approved_hours_left,
                  :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def passed(mail_data)
    subject       I18n.t('mailers.drafting.passed.subject')
    from          "drafting@echo.to"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :language => mail_data[:language]
  end

  def supporters_passed(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_passed.subject')
    from          "drafting@echo.to"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :ip_link => statement_node_url(mail_data[:incorporable]),
                  :language => mail_data[:language]
  end

  def incorporated(mail_data)
    subject       I18n.t('mailers.drafting.incorporated.subject')
    from          "drafting@echo.to"
    recipients    mail_data[:draftable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:draftable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def incorporation_notification(recipients, mail_data)
    subject       I18n.t('mailers.drafting.incorporation_notification.subject')
    from          "drafting@echo.to"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title.strip,
                  :p_title => mail_data[:draftable_document].title.strip,
                  :p_link => statement_node_url(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

end
