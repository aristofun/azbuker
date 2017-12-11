R_ROOT = File.dirname(__FILE__) + '/..'
require File.expand_path(R_ROOT + "/lib/azb_utils")

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
#set :output, "/usr/sites/azbuker/shared/log/cron_log.log"
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every 15.day, :at => '6:10 am' do
  command AzbUtils.pgdump_string(AzbUtils::DB, "-T oz_books", "#{AzbUtils::MAIN_FILE}.bz2")
end

every 15.day, :at => '6:25 am' do
  command AzbUtils.upload_string("#{AzbUtils::MAIN_FILE}.bz2")
end

every 49.days, :at => '6:40 am' do
  command AzbUtils.pgdump_string(AzbUtils::DB, "-t oz_books", "#{AzbUtils::OZB_FILE}.bz2")
end

every 49.days, :at => '6:55 am' do
  command AzbUtils.upload_string("#{AzbUtils::OZB_FILE}.bz2")
end

# Learn more: http://github.com/javan/whenever
