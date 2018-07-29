require 'bundler/capistrano'
require 'capistrano-rbenv'
set :whenever_command, 'bundle exec whenever'

require 'whenever/capistrano'

server ENV['cap_host'] || 'azbuker.ru', :web, :app, :db, :primary => true

set :application, 'azbuker'

set :user, 'joe'
set :repository, 'git@github.com:aristofun/azbuker.git'
set :scm, :git
set :branch, 'master'
set :apps_dir, ENV['cap_apps_dir'] || '/home/joe/apps' # old: /usr/sites
set :deploy_to, "#{apps_dir}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :rbenv_ruby_version, ENV['cap_ruby'] || '2.1.10'
# set :rbenv_type, :user
# set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# set :rbenv_map_bins, %w{rake gem bundle ruby rails}
# set :rbenv_roles, :all # default value


default_run_options[:pty] = true
ssh_options[:forward_agent] = true
#default_run_options[:env] = {'RAILS_ENV' => 'production'}

#role :web, "nginx"                          # Your HTTP server, Apache/etc
#role :app, "passenger"                          # This may be the same as your `Web` server
#role :db,  "postgres", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# https://stackoverflow.com/a/26509175
before 'deploy:assets:precompile', 'my:symlink_files'

after 'deploy:restart', 'deploy:cleanup'
after 'deploy:restart', 'my:init_error_pages'
# after 'deploy:update_code', 'my:sync_ozbooks_counter'
before 'deploy:update', 'my:backup:main' unless ENV['nobackup']
before 'deploy:update', 'my:backup:all' if ENV['backupall']
after 'deploy:restart', 'my:sync_uploads' #unless ENV['nobackup']

after 'deploy:web:enable', 'my:restart_nginx'
after 'deploy:web:disable', 'my:restart_nginx'

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  desc 'reload the database with seed data'
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
end


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    ;
  end
  task :stop do
    ;
  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

task :pushdep do
  system "git commit -am 'capistrano #{Time.now}'"
  system 'git push'
  deploy.update
  deploy.restart
end

#=======================
namespace :my do
  desc 'Symlinking system files outside the Git'
  task :symlink_files, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/.env #{release_path}/.env"
  end

  task :restart_all, :roles => :app, :except => {:no_release => true} do
    puts 'Restarting nginx...'
    run 'sudo service nginx restart'
    puts 'Restarting PostgreS...'
    run 'sudo service postgresql restart'
  end

  task :restart_nginx, :roles => :app, :except => {:no_release => true} do
    puts 'Restarting nginx...'
    run 'sudo service nginx restart'
  end


  desc 'Remote Rake on Production ENV! Be careful.'
  task :remote_rake, :roles => :app do
    run_rake(ENV['task'])
  end

  desc 'Remote Rake on Production ENV! Be careful.'
  task :console, :roles => :app do
    # command = "cd #{latest_release} && /usr/bin/env bundle exec rails console production"
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.profile && cd #{current_path}; bundle exec rails console #{rails_env}'"
  end

  namespace :backup do
    task :all do
      main
      ozb
    end

    task :main do
      dump_db(AzbUtils::DB, '-T oz_books', "#{AzbUtils::MAIN_FILE}.bz2")
      run AzbUtils.upload_string("#{AzbUtils::MAIN_FILE}.bz2")
    end

    task :ozb do
      dump_db(AzbUtils::DB, '-t oz_books', "#{AzbUtils::OZB_FILE}.bz2")
      run AzbUtils.upload_string("#{AzbUtils::OZB_FILE}.bz2")
    end
  end

  namespace :restore do
    task :all do
      main
      ozb
    end
    task :main do
      restore_db(AzbUtils::DB, AzbUtils::MAIN_FILE)
    end
    task :ozb do
      restore_db(AzbUtils::DB, AzbUtils::OZB_FILE)
    end
  end

  desc "Run: cap my:sync_ozbooks_counter local_path=/Volumes/other/2cloud/uploads/azbuker/"
  task :sync_ozbooks_counter do
    unless ENV['local_path']
      puts 'local_path not set! ignoring :sync_ozbooks_counter'
      next
    end

    local = "#{ENV['local_path']}/system/ozbooks/"
    remote = "#{user}{@azbuker.ru:#{apps_dir}/#{application}{/shared/system/ozbooks/"
    system("rsync -qrpt --rsh=ssh  #{remote} #{local}")
    # system("rsync -qrpt --rsh=ssh  #{local} #{remote}")
  end

  desc "Run: cap my:sync_uploads local_path=/Volumes/other/2cloud/uploads/azbuker/"
  task :sync_uploads do
    unless ENV['local_path']
      puts 'local_path not set! ignoring :sync_uploads'
      next
    end

    local = "#{ENV['local_path']}/system/"
    remote = "#{user}@azbuker.ru:#{apps_dir}/#{application}/shared/system/"

    if ENV['upload']
      system("rsync -qrpt --delete --progress --rsh=ssh #{local} #{remote}")
    else
      system("rsync -qrpt --progress --delete --rsh=ssh #{remote} #{local}")
    end
  end

  task :init_error_pages do
    system 'curl -s http://azbuker.ru/500.html?forcache=1'
    system 'curl -s http://azbuker.ru/404.html?forcache=1'
  end

  def run_rake(task, options={}, &block)
    command = "cd #{latest_release} && /usr/bin/env bundle exec rake #{task} RAILS_ENV=production"
    run(command, options, &block)
  end

  def restore_db(db, file)
    down_db(file) if ENV['dropbox']
    run "bunzip2 -f -k #{file}.bz2"
    run "psql -U postgres -h localhost -f #{file} #{db}"
    run "rm -f #{file}"
  end

  def dump_db(db, table, file)
    run AzbUtils.pgdump_string(db, table, file)
  end

  def down_db(file)
    run "./dropbox_uploader.sh download Apps/azb_upload/#{file}.bz2 #{file}.bz2"
  end
end


