# coding: utf-8
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/tasks/'
  add_filter 'app/admin/'
  add_filter 'ozon_book_parser'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rails'
require 'capybara/rspec'
require 'paperclip/matchers'
require 'lots_populator'

#require 'factory_girl_rails'   look next line
#FactoryBot.find_definitions  # can help if rake don't find factories

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.infer_spec_type_from_file_location!

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  config.order = "33439" # 4752
  #config.order = "4752"  # 4752

  # XXX  monkey patch to make fresh Capybara work inside requests specs
  # http://stackoverflow.com/questions/8862967/visit-method-not-found-in-my-rspec
  config.include Capybara::DSL


  def login(user, backw_path = root_path, confirm = true)
    if user.confirmation_token.present? && user.confirmed_at.blank? && confirm
      #p user_confirmation_path(:confirmation_token => user.confirmation_token)
      #p user.inspect
      visit user_confirmation_path(:confirmation_token => user.confirmation_token)
    else
      visit user_session_path

      within(:xpath, "//form[@action='#{user_session_path}']") do
        fill_in 'user_email', :with => user.email
        fill_in 'user_password', :with => user.password
        click_button "Войти"
      end

    end

    if (page.current_path == backw_path) &&
        page.has_no_selector?("div.alert-message", :text => I18n.t("devise.failure.invalid")) &&
        page.has_no_selector?("div.alert-message", :text => I18n.t("devise.failure.unconfirmed"))
      user.reload
      true
    else
      false
    end
  end

  def logout(user)
    begin
      visit destroy_user_session_path
      user.reload
      true
    rescue StandardError => exc
      p "ERROR logging out user: #{user.id}"
      p exc.message
      false
    end
  end

  def match_selector_content(selector, content)
    have_selector(selector, :text => content)
  end

  def dimensions(file)
    Paperclip::Geometry.from_file(file)
  end

  config.include Devise::TestHelpers, :type => :controller
  config.include Paperclip::Shoulda::Matchers
  config.include LotsPopulator

  config.after(:all) do
    #puts "/ clean db: #{Lot.delete_all} lots, #{Book.delete_all} books,"\
    #     "#{Author.delete_all} authrs, #{User.delete_all} usrs "

    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/covers/"]) if Rails.env.test?
    #puts FileUtils.rm_rf(Dir["#{Rails.root}/public/covers/lots"])
  end
end

module Rack
  module Test
    class UploadedFile
      #def tempfile     XXX monkeypatch for test file uploader problem. Now solved
      #  @tempfile
      #end
    end
  end
end

shared_examples_for "ActiveModel" do
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map { |m| m.to_s }.grep(/^test/).each do |m|
    example m.gsub('_', ' ') do
      send m
    end
  end

  def model
    subject
  end
end
