namespace :admin do
  desc "Clean up all temporary files in the application directory"
  task :cleanup => :environment do
    puts "Removing temporary directory contents"
    Rake::Task["tmp:clear"].invoke
    puts "Removing log files"
    Rake::Task["log:clear"].invoke
  end
end