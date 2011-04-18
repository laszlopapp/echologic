# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
MAX_SESSION_PERIOD = 1*24*60*60

GITHUB_URL = 'http://github.com/echosystem/echo'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Access control list gem Acl9.
  config.gem "acl9", :lib => "acl9", :source => "http://gemcutter.org"
  config.gem 'ezcrypto'

  # Authlogic authentication gem with RPX extension.
  config.gem 'authlogic', :version => '>= 2.1.5', :lib => "authlogic", :source => "http://gems.github.com"

  # Require formtastic gem to build semantic forms
  config.gem "formtastic"

  # Unit testing
  config.gem 'test-unit', :lib => 'test/unit'

  # require shoulda to use it for testing :)
  config.gem 'shoulda'

  # Mocks for testing
  config.gem 'flexmock'

  # gem for background processing
  config.gem 'delayed_job'

  # gem for running the background jobs in production
  config.gem 'daemons'

  # gems for endless pagination
  config.gem 'will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'

  config.gem 'rest-open-uri'

  config.gem 'uuidtools'

  config.gem 'sanitize'

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

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :en

  # Authologic RPX
  RPX_APP_NAME = ENV['ECHO_RPX_APP_NAME']
  RPX_API_KEY = ENV['ECHO_RPX_API_KEY']

  # Setting RPX data in EngineYard environment
  require File.join(File.dirname(__FILE__), 'rpx_config')

  raise "RPX/Janrain Engage API key must be defined ENV['ECHO_RPX_API_KEY']" unless RPX_API_KEY
  raise "RPX/Janrain Engage Application Name must be defined ENV['ECHO_RPX_APP_NAME']" unless RPX_APP_NAME

  # Questions per page
  QUESTIONS_PER_PAGE = 7

  # Session Storage
  config.action_controller.session_store = :active_record_store

  # add load paths for models in subfolders... this can be extended by further subfolders if neccessary
  config.load_paths += %w(statements mailers).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}
  # the same for controllers
  config.load_paths += %w(statements).collect{|dir|"#{RAILS_ROOT}/app/controllers/#{dir}"}
  # libs
  config.load_paths += %w(activity_tracking_service drafting_service echo_service social_service).collect{|dir|"#{RAILS_ROOT}/lib/#{dir}"}
end
