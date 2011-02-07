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
    config.action_links.add 'send_newsletter', :label => 'Send Newsletter!', :type => :record, :method => :put, :page => true, :confirm => I18n.t("newsletters.send_confirmation")
    config.list.per_page = 10
    Language.all.each do |l|
      config.action_links.add :index, :label => l.value, :parameters => {:locale => l.code}, :page => true
    end
  end

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
