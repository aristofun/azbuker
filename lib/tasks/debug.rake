
namespace :admin do
  desc 'bundle debug handler for RubyMine'
  task :debug_guard do
    p "Running bundle exec guard..."
    system("bundle exec guard")
    p "complete!"
  end
end