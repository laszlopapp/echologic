# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
MAX_SESSION_PERIOD = 36     # in hours

GITHUB_URL = 'http://github.com/echosystem/echo'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %w(statements mailers).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}
  config.load_paths += %w(statements).collect{|dir|"#{RAILS_ROOT}/app/controllers/#{dir}"}
  config.load_paths += %w(activity_tracking_service drafting_service echo_service social_service).collect{|dir|"#{RAILS_ROOT}/lib/#{dir}"}

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Authentication / Authorisation
  config.gem 'acl9', :version => '0.12.0'
  config.gem 'authlogic', :version => '2.1.6'

  # Application libs
  config.gem 'formtastic', :version => '1.1.0'
  config.gem 'i18n', :version => '0.4.2'
  #config.gem 'mysql', :version => '2.8.1'
  config.gem 'rails_sql_views', :version => '0.8.0'
  config.gem 'will_paginate', :version => '2.3.15'

  # Utility libraries
  config.gem 'ezcrypto', :version => '0.7.2'
  config.gem 'rest-open-uri', :version => '1.0.0'
  config.gem 'sanitize', :version => '2.0.1'
  config.gem 'uuidtools', :version => '2.1.2'

  # Background jobs
  config.gem 'daemons', :version => '1.1.3'
  config.gem 'delayed_job', :version => '2.0.3'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # Action Mailer
  config.action_mailer.default_charset = "utf-8"
  SMTP_HOST = ENV['ECHO_SMTP_HOST']
  SMTP_USER = ENV['ECHO_SMTP_USER']
  SMTP_PASS = ENV['ECHO_SMTP_PASS']
  require File.join(File.dirname(__FILE__), 'smtp_config') # Setting SMTP data in EngineYard environment

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :en

  # Authlogic RPX
  RPX_APP_NAME = ENV['ECHO_RPX_APP_NAME']
  RPX_API_KEY = ENV['ECHO_RPX_API_KEY']
  require File.join(File.dirname(__FILE__), 'rpx_config') # Setting RPX data in EngineYard environment
  raise "RPX/Janrain Engage API key must be defined ENV['ECHO_RPX_API_KEY']" unless RPX_API_KEY
  raise "RPX/Janrain Engage Application Name must be defined ENV['ECHO_RPX_APP_NAME']" unless RPX_APP_NAME

  # Questions per page
  QUESTIONS_PER_PAGE = 7

  # Session Storage
  config.action_controller.session_store = :active_record_store

end
