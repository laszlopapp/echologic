class NewslettersController < ApplicationController
  layout 'admin'
  helper :mail

  before_filter :require_user, :except => [:show]

  access_control do
    allow :admin
    allow anonymous, :to => [:show]
  end

  active_scaffold :newsletters do |config|
    config.label = "Newsletters"
    config.columns = [:subject, :text, :default_greeting, :default_goodbye, :created_at]
    config.columns[:default_greeting].form_ui = :checkbox
    config.columns[:default_greeting].inplace_edit=true
    config.columns[:default_goodbye].form_ui = :checkbox
    config.columns[:default_goodbye].inplace_edit=true
    config.create.columns = [:subject, :text]
    config.update.columns = [:subject, :text]
    list.sorting = [{:created_at => 'DESC'}]
    config.show.link.page = true
    config.action_links.add 'test_newsletter',
                            :label => 'TEST MAIL',
                            :type => :record,
                            :method => :put,
                            :page => true
    config.action_links.add 'send_newsletter',
                            :label => 'Send Newsletter!',
                            :type => :record,
                            :method => :put,
                            :page => true,
                            :confirm => I18n.t("newsletters.send_confirmation")
    config.list.per_page = 10
    Language.all.each do |l|
      config.action_links.add :index,
                              :label => l.value,
                              :parameters => {:locale => l.code},
                              :page => true
    end
  end

  def test_newsletter
    newsletter = Newsletter.find(params[:id])
    NewsletterMailer.deliver_newsletter_mail(current_user, newsletter, true)
    redirect_to newsletters_path
  end

  def send_newsletter
    newsletter = Newsletter.find(params[:id])
    MailerService.instance.send_newsletter_mails(newsletter)
    redirect_to newsletters_path
  end

  def show
    newsletter = Newsletter.find(params[:id])
    @name = current_user ? current_user.full_name : I18n.t('mailers.echo_community')
    @text = newsletter.text
    @language = Language[I18n.locale]
    @no_greeting = !newsletter.default_greeting
    @no_goodbye = !newsletter.default_goodbye
    respond_to do |format|
      format.html {render :template => 'newsletters/show',
                          :layout => 'mail_online'}
    end
  end
end
