class NewsletterMailer < ActionMailer::Base
  layout 'mail'
  helper :mail

  # Send a newsletter to the given user.
  def newsletter_mail(recipient, newsletter)
    spoken_languages = recipient.sorted_spoken_languages.map{|id|Language[id].code}
    current_code = I18n.locale
    newsletter.disable_translation
    title = newsletter.title
    text = newsletter.text
    newsletter.enable_translation
    
    spoken_languages.each do |code|
      I18n.locale = code
      if newsletter.translation_locale == code or code == I18n.default_locale.to_s
        title = newsletter.title
        text = newsletter.text
        break
      end
    end
    I18n.locale = current_code
    
    
    language = recipient.default_language
    subject       title
    recipients    recipient.email
    from          "noreply@echologic.org"
    sent_on       Time.now
    content_type  "text/html"
    body          :name => recipient.full_name,
                  :text => text,
                  :language => language
  end
end
