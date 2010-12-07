class NewsletterController < ApplicationController

  skip_before_filter :require_user, :only => [:new, :create]

  access_control do
    allow :admin
  end

  # GET /new
  def new
    respond_to do |format|
      format.html
    end
  end

  # GET /create
  def create
    subject = params[:newsletter][:subject]
    text = params[:newsletter][:text]
    respond_to do |format|
      format.js do
        if !subject.blank? and !text.blank?
          if params[:newsletter][:test].eql?('true')
            NewsletterMailer.deliver_newsletter_mail(current_user, subject, text)
            show_info_messages "Test newsletter mail has been sent to your address."
          else
            MailerService.instance.send_newsletter_mails(subject, text)
            render :template => 'newsletter/create'
          end
        else
          show_error_message I18n.t("mailers.newsletter.fields_not_filled")
        end
      end
    end
  end

end
