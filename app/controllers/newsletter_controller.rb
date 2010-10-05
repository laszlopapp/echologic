class NewsletterController < ApplicationController
  # GET /feedback/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # POST /feedback
  def create
    subject = params[:newsletter][:subject]
    text = params[:newsletter][:text]
    respond_to do |format|
      format.js do
        if !subject.blank? and !text.blank?
          User.all.select{|u| u.newsletter_notification == 1}.each do |user|
            AdminMailer.deliver_newsletter(user, subject, text)
          end
          render :template => 'newsletter/create'
        else
          set_error("mailers.newsletter.fields_not_filled")
          show_error_messages
        end
      end
    end
  end

  # Rescues eventually occuring errors and handles them by redirecting to
  # the feedback page with error message in the flash storage.
  # TODO errors as an array in flash, currently just one error per request.
  def rescue2_action(exception)
    case (exception)
      when NotComplete
        then flash[:error] = t('activerecord.errors.models.newsletter.attributes.blank')
      when Net::SMTPSyntaxError
        then flash[:error] = t('activerecord.errors.models.newsletter.attributes.email.invalid')
    end
    redirect_to new_newsletter_path
  end
end
