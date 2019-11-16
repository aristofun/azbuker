# XXX: http://stackoverflow.com/questions/35999906/pg-dump-invalid-option-i-when-migrating
# postgres 9.6 compatibility issue
#
require 'active_support/core_ext/object/inclusion'
require 'active_record'

Rake::Task["db:structure:dump"].clear

namespace :db do
  namespace :structure do
    desc 'MY! Dump the database structure to db/structure.sql. Specify another file with DB_STRUCTURE=db/my_structure.sql'
    task :dump => [:environment, :load_config] do
      config = current_config
      filename = ENV['DB_STRUCTURE'] || File.join(Rails.root, "db", "structure.sql")
      case config['adapter']
        when /mysql/, 'oci', 'oracle'
          ActiveRecord::Base.establish_connection(config)
          File.open(filename, "w:utf-8") { |f| f << ActiveRecord::Base.connection.structure_dump }
        when /postgresql/
          set_psql_env(config)
          search_path = config['schema_search_path']
          unless search_path.blank?
            search_path = search_path.split(",").map { |search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
          end
          `pg_dump -s -x -O -f #{Shellwords.escape(filename)} #{search_path} #{Shellwords.escape(config['database'])}`
          raise 'Error dumping database' if $?.exitstatus == 1
          File.open(filename, "a") { |f| f << "SET search_path TO #{ActiveRecord::Base.connection.schema_search_path};\n\n" }
        when /sqlite/
          dbfile = config['database']
          `sqlite3 #{dbfile} .schema > #{filename}`
        when 'sqlserver'
          `smoscript -s #{config['host']} -d #{config['database']} -u #{config['username']} -p #{config['password']} -f #{filename} -A -U`
        when "firebird"
          set_firebird_env(config)
          db_string = firebird_db_string(config)
          sh "isql -a #{db_string} > #{filename}"
        else
          raise "Task not supported by '#{config['adapter']}'"
      end

      if ActiveRecord::Base.connection.supports_migrations?
        File.open(filename, "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      end
      Rake::Task["db:structure:dump"].reenable
    end
  end
end

def current_config(options = {})
  options = { :env => Rails.env }.merge! options

  if options[:config]
    @current_config = options[:config]
  else
    @current_config ||= if ENV['DATABASE_URL']
                          database_url_config
                        else
                          ActiveRecord::Base.configurations[options[:env]]
                        end
  end
end

def set_psql_env(config)
  ENV['PGHOST']     = config['host']          if config['host']
  ENV['PGPORT']     = config['port'].to_s     if config['port']
  ENV['PGPASSWORD'] = config['password'].to_s if config['password']
  ENV['PGUSER']     = config['username'].to_s if config['username']
end

