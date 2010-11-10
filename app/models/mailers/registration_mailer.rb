class RegistrationMailer < ActionMailer::Base

  # Delivers activation instructions to the given user.
  # TODO i18n see view
  def activation_instructions(user)
    subject       I18n.t('mail.activation.subject')
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.full_name, :activation_url => register_url(user.perishable_token)
  end

  # Provides an activation for the given user.
  # TODO i18n see view
  def activation_confirmation(user)
    subject       I18n.t('mail.welcome.subject')
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.full_name
  end

  # Send a password reset email containing a link to reset via perishable_token.
  def password_reset_instructions(user)
    subject       I18n.t('mail.new_password.subject')
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.full_name, :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
