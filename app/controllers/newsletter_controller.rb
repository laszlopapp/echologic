class NewsletterController < ApplicationController

  skip_before_filter :require_user, :only => [:new, :create]


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
            AdminMailer.deliver_newsletter(current_user, subject, text)
          else
            User.all.select{|u| u.newsletter_notification == 1}.each do |user|
              AdminMailer.deliver_newsletter(user, subject, text)
            end
          end
          render :template => 'newsletter/create'
        else
          set_error("mailers.newsletter.fields_not_filled")
          show_error_messages
        end
      end
    end
  end

end
