class NewslettersController < ApplicationController
  layout 'admin'
  
  skip_before_filter :require_user, :only => [:new, :create]

  access_control do
    allow :admin
  end

  active_scaffold :newsletters do |config|
    config.label = "Newsletters"
    config.columns = [:title, :text,:created_at]
    list.sorting = [{:created_at => 'DESC'}]
    config.action_links.add 'test_newsletter', :label => 'TEST MAIL', :type => :record, :method => :put, :page => true
    config.action_links.add 'send_newsletter', :label => 'Send Newsletter!', :type => :record, :method => :put, :page => true, :confirm => true
    config.list.per_page = 10
    Language.all.each do |l|
      config.action_links.add :index, :label => l.value, :parameters => {:locale => l.code}, :page => true
    end
  end

  # GET /new
#  def new
#    respond_to do |format|
#      format.html
#    end
#  end
#
#  # GET /create
#  def create
#    subject = params[:newsletter][:subject]
#    text = params[:newsletter][:text]
#    respond_to do |format|
#      format.js do
#        if !subject.blank? and !text.blank?
#          if params[:newsletter][:test].eql?('true')
#            NewsletterMailer.deliver_newsletter_mail(current_user, subject, text)
#            render_with_info "Test newsletter mail has been sent to your address."
#          else
#            MailerService.instance.send_newsletter_mails(subject, text)
#            render :template => 'newsletter/create'
#          end
#        else
#          set_error 'mailers.newsletter.fields_not_filled' and render_with_error 
#        end
#      end
#    end
#  end

  def test_newsletter
    newsletter = Newsletter.find(params[:id])
    NewsletterMailer.deliver_newsletter_mail(current_user, newsletter)
    redirect_to newsletters_path
  end
  
  def send_newsletter
    newsletter = Newsletter.find(params[:id])
    MailerService.instance.send_newsletter_mails(newsletter)
    redirect_to newsletters_path
  end

end
