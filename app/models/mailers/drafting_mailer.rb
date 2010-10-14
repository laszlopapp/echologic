require 'drafting_service'

class DraftingMailer < ActionMailer::Base
  include StatementsHelper

  def approval(mail_data)
    subject       I18n.t('mailers.drafting.approval.subject')
    from          "noreply@echologic.org"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title,
                  :hours => DraftingService.approved_hours,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def supporters_approval(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_approval.subject')
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :hours => DraftingService.approved_hours,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def approval_notification(recipients, mail_data)
    subject       I18n.t('mailers.drafting.approval_notification.subject')
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def approval_reminder(mail_data)
    subject       I18n.t('mailers.drafting.approval_reminder.subject')
    from          "noreply@echologic.org"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :hours => DraftingService.approved_hours_left,
                  :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def supporters_approval_reminder(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_approval_reminder.subject')
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :hours => DraftingService.approved_hours_left,
                  :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def passed(mail_data)
    subject       I18n.t('mailers.drafting.passed.subject')
    from          "noreply@echologic.org"
    recipients    mail_data[:incorporable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:incorporable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :language => mail_data[:language]
  end

  def supporters_passed(recipients, mail_data)
    subject       I18n.t('mailers.drafting.supporters_passed.subject')
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :ip_link => improvement_proposal_path(mail_data[:incorporable]),
                  :language => mail_data[:language]
  end

  def incorporated(mail_data)
    subject       I18n.t('mailers.drafting.incorporated.subject')
    from          "noreply@echologic.org"
    recipients    mail_data[:draftable_document].author.email
    sent_on       Time.now
    body          :name => mail_data[:draftable_document].author.full_name,
                  :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

  def incorporation_notification(recipients, mail_data)
    subject       I18n.t('mailers.drafting.incorporation_notification.subject')
    from          "noreply@echologic.org"
    bcc           recipients.map(&:email)
    sent_on       Time.now
    body          :ip_title => mail_data[:incorporable_document].title,
                  :p_title => mail_data[:draftable_document].title,
                  :p_link => proposal_path(mail_data[:draftable]),
                  :language => mail_data[:language]
  end

end
