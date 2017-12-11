# coding: utf-8
require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'sprockets/railtie'
require 'will_paginate/view_helpers'
require 'cssminify'


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))

  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Azbuker
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    #config.before_configuration do
      #config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      #config.i18n.default_locale = :ru
      #config.i18n.locale = :ru
      # bypasses rails bug with i18n in production\
      #I18n.reload!
      #config.i18n.reload!
    #end

    config.i18n.default_locale = :ru
    config.i18n.locale = :ru

    # rails will fallback to en, no matter what is set as config.i18n.default_locale
    config.i18n.fallbacks = [:en]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    I18n.enforce_available_locales = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.css_compressor = CSSminify.new

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.1'

    config.azbuker_name = 'Азбукер'

    config.abusemail = 'abuse@azbuker.ru'

    config.paths['app/views'] << 'app/views/devise'

    # own paginator for Bootstrap
    #WillPaginate::ViewHelpers.pagination_options[:previous_label] = "<strong>&#9664;</strong>"
    #WillPaginate::ViewHelpers.pagination_options[:next_label] = "<strong>&#9654;</strong>"
    WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2
    WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0
    #config.action_controller.include_all_helpers = false
  end
end
