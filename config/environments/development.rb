if RUBY_PLATFORM =~ /mswin/i
  require 'rubygems'
  require 'faster_require'
end

Azbuker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot
  config.eager_load = false
  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {:host => 'localhost:3000'}

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = true

  config.backemail = 'azbuker@azbuker.ru'

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.log_level = :debug

  # Do not compress assets
  config.assets.compress = false

  #config.assets.digest = true

  # Expands the lines which load the assets
  config.assets.debug = true

  Hirb.enable
  Paperclip.options[:command_path] = '/usr/local/bin/'
end
