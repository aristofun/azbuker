# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Azbuker::Application.initialize!

begin
  if RUBY_PLATFORM =~ /mswin/i
    require 'rubygems'
    require 'win32console'
    #require 'Win32/Console/ANSI'
  end
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end
