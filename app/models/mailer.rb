class Mailer < ActionMailer::Base
  
    handle_asynchronously :feedback, :activation_instructions, :activation_confirmation, :password_reset_instructions,
                          :activity_tracking_email

  # Send a feedback object as email to the FEEDBACK_RECIPIENT specified
  # in the environment.
  def feedback(feedback)  
    subject       "echologic - Feedback from #{feedback.name}"
    recipients    FEEDBACK_RECIPIENT
    from          "feedback@echologic.org"
    reply_to      [feedback.email, FEEDBACK_RECIPIENT]
    sent_on       Time.now
    body          :name => feedback.name, :message => feedback.message
  end

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
end
