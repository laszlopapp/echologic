class Mailer < ActionMailer::Base

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
    body          :name => user.profile.full_name, :activation_url => register_url(user.perishable_token)
  end

  # Provides an activation for the given user.
  # TODO i18n see view
  def activation_confirmation(user)
    subject       I18n.t('mail.welcome.subject')
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.profile.full_name
  end

  # Send a password reset email containing a link to reset via perishable_token.
  def password_reset_instructions(user)
    subject       I18n.t('mail.new_password.subject')
    from          "noreply@echologic.org"
    recipients    user.email
    sent_on       Time.now
    body          :name => user.profile.full_name, :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  # Send the activities on the subscribed objects to the subscribeable
  def activity_tracking_email(subscriber)
    subject       "Activity Tracking" #to be internationalized
    from          "noreply@echologic.org"
    recipients    subscriber.email
    sent_on       Time.now
    body          :events => Event.find_by_sql(
                          sanitize_sql(["SELECT * from events e 
                                         LEFT JOIN statement_nodes s ON s.id = e.subscribeable_id
                                         where (s.parent_id = NULL or s.parent_id IN (?))
                                               and e.created_at > ?
                                         order_by type DESC 
                                                  created_at DESC",subscriber.subscribeables.map{|s|s.id},7.days.ago]))
  end
end
