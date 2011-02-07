class NewsletterMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send a newsletter to the given user.
  def newsletter_mail(recipient, newsletter)
    spoken_languages = recipient.sorted_spoken_languages.map{|id|Language[id].code}
    newsletter.disable_translation
    language_code = I18n.default_locale.to_s
    title = newsletter.title
    text = newsletter.text
    newsletter.enable_translation
    
    spoken_languages.each do |code|
      break if code == I18n.default_locale.to_s
      translation = newsletter.translations.find_by_locale(code)
      if !translation.nil?
        language_code = code
        title = translation.title
        text = translation.text
        break
      end
    end
    
    language = recipient.default_language
    subject       title
    recipients    recipient.email
    from          "noreply@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => recipient.full_name,
                  :text => text,
                  :language => Language[language_code]
  end
end
