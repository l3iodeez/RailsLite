require 'pg'
require 'byebug'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
ROOT_FOLDER = File.join(File.dirname(__FILE__), '..')
SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')

class DBConnectionPG
  def self.open(db_name)

  if ENV['DATABASE_URL']
    connection_details = {
      url: ENV['DATABASE_URL']
    }
  else
    connection_details = {
      dbname: db_name,
    }
  end
    @db = PG::Connection.new(connection_details)
    byebug
    @db
  end

  def self.reset(db_name)
    raise "No connection open" unless instance
    instance.exec_params(<<-SQL
      select 'drop table if exists "' || tablename || '" cascade;'
        from pg_tables
      where schemaname = '#{db_name}';
    SQL
    )
    file = File.open(SQL_FILE, "rb")
    setup_script = file.read
    file.close
    instance.exec(setup_script)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.get_first_row(*args)
    instance.exec_params(*args).first
  end

  def self.execute(*args)
    instance.exec_params(*args)
  end

end
