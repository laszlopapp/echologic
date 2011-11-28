ActionMailer::Base.smtp_settings = {
  :address => SMTP_HOST,
  :port => 25,
  :domain => 'echo.to',
  :authentication => :login,
  :enable_starttls_auto => true,
  :user_name => SMTP_USER,
  :password => SMTP_PASS
}

ActionMailer::Base.raise_delivery_errors = true
