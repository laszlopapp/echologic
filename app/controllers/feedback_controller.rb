# To handle smtp exceptions include the net/smtp-module.
require 'net/smtp'

# Error to indicate the feedback form wasn't filled out completely.
# Thrown by: mailer
class NotComplete < StandardError
end

class FeedbackController < ApplicationController

  skip_before_filter :require_user, :only => [:new, :create]


  # GET /feedback/new
  def new
    render_static_new :partial => 'feedback/new'
  end

  # POST /feedback
  def create
    @feedback = Feedback.new(params[:feedback])
    respond_to do |format|
      format.js do
        if @feedback.save
          FeedbackMailer.deliver_feedback(@feedback)
          render :template => 'feedback/create'
        else
          set_error @feedback and render_with_error
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
        then flash[:error] = t('activerecord.errors.models.feedback.attributes.blank')
      when Net::SMTPSyntaxError
        then flash[:error] = t('activerecord.errors.models.feedback.attributes.email.invalid')
    end
    render_static_show :partial => 'feedback/new',
                       :template_js => 'layouts/outerMenuDialog',
                       :locals => { :menu_item => 'feedback/new' }
  end


end
