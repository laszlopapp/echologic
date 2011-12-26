class NewsletterMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send a newsletter to the given user.
  def newsletter_mail(recipient, newsletter, current_language = false)
    preferred_languages = current_language ? [I18n.locale.to_s] : recipient.preferred_languages.map(&:code)
    newsletter.disable_translation
    language_code = I18n.default_locale.to_s
    subject = newsletter.subject
    text = newsletter.text
    default_greeting = newsletter.default_greeting
    default_goodbye = newsletter.default_goodbye
    newsletter.enable_translation

    preferred_languages.each do |code|
      break if code == I18n.default_locale.to_s
      translation = newsletter.translations.find_by_locale(code)
      if !translation.nil?
        language_code = code
        subject = translation.subject
        text = translation.text
        break
      end
    end

    subject       subject
    recipients    recipient.email
    from          "news@echo.to"
    sent_on       Time.now
    content_type  "text/html"
    body          :online_url => newsletter_url(newsletter, :locale => language_code),
                  :name => recipient.full_name,
                  :text => text,
                  :language => Language[language_code],
                  :no_greeting => !default_greeting,
                  :no_goodbye => !default_goodbye
  end
end
