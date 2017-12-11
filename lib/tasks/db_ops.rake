namespace :db do
  desc 'rebuild the database from scratch'
  task :rebuild do
    p "env: " + Rails.env
    #Rake::Task["db:create:all"].invoke

    p "Beggining the rebuild for DEV: "
    rebild('development')
    p "DEV rebuilt "

    p "Rebuilding TEST:"
    rebild('test')
    p "all complete!"
  end

  desc 'rebuild the test DB from scratch'
  task :rezet_test do
    p "Rebuilding TEST:"
    rebild('test')
    p "all complete!"
  end

  desc 'cleanup oz_books with invalid cover img. [from_id, to_id]'
  task :clean_ozbooks, [:from_id, :to_id] => [:environment] do |t, args|
    from_id = args[:from_id].to_i
    to_id = args[:to_id].to_i

    agent = Mechanize.new
    agent.keep_alive = false
    start = Time.now
    puts "start cleanup from #{from_id} to #{to_id}, time: #{start}"

    OzBook.where("id >= #{from_id} AND id <= #{to_id}").find_each do |ozbook|
      unless OzonBookParser.cover_exist(agent, ozbook.ozon_coverid)
        #puts "delet: #{ozbook.id}, ozonid: #{ozbook.ozonid}"
        print "#{ozbook.id},"
      end
      sleep 0.01
    end

    delta = Time.now - start
    puts "total time: #{delta} sec.,  #{((to_id - from_id)/delta).round(2)} b/sec"
  end

  def rebild(env = 'development')
    system("rake db:drop RAILS_ENV=#{env}")
    system("rake db:create RAILS_ENV=#{env}")
    system("rake db:migrate RAILS_ENV=#{env}")
    system("rake db:seed RAILS_ENV=#{env}")
    system("rake db:test:prepare RAILS_ENV=#{env}") if env == 'test'
  end

end