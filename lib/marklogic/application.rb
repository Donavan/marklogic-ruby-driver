module MarkLogic
  # Represents an application on a MarkLogic server
  class Application
    include MarkLogic::Persistence

    attr_accessor :app_name, :port

    def initialize(app_name, options = {})
      @app_name = app_name
      self.connection = options[:connection]
      @port = options[:port] || connection.port
      self.admin_connection = options[:admin_connection]
    end

    def create
      logger.debug(%(Creating Application: #{@app_name}))

      build_implicit_defs

      update_or_create_databases
      create_forests
      update_or_create_app_servers
    end

    def create_indexes
      build_implicit_defs
      update_or_create_databases
    end

    def sync
      create if stale?
    end

    def sync!
      create
    end

    def drop
      logger.debug(%(Dropping Application: #{@app_name}))

      build_implicit_defs

      app_servers.each do |_server_name, app_server|
        app_server.drop if app_server.exists?
      end

      databases.each do |_database_name, database|
        database.drop if database.exists?
      end

      forests.each do |_forest_name, forest|
        forest.drop if forest.exists?
      end
    end

    def exists?
      build_implicit_defs

      databases.each do |_database_name, database|
        return false unless database.exists?
      end

      forests.each do |_forest_name, forest|
        return false unless forest.exists?
      end

      app_servers.each do |_server_name, app_server|
        return false unless app_server.exists?
      end

      true
    end

    def stale?
      build_implicit_defs
      return true if stale_check(:databases) || stale_content_databases? || stale_check(:forests) || stale_check(:app_servers)
      false
    end

    def stale_content_databases?
      content_databases.any?(&:stale?)
    end

    def stale_check(what)
      send(what).any? { |_name, obj| !obj.exists? }
    end

    def forests
      @forests ||= {}
    end

    def databases
      @databases ||= {}
    end

    def app_servers
      @app_servers ||= {}
    end

    def add_index(index)
      indexes[index.key] = index
    end

    def clear_indexes
      content_databases.each(&:reset_indexes)
      @indexes = {}
    end

    def content_databases
      app_servers.values.map do |app_server|
        databases[app_server['content-database']]
      end
    end

    def modules_databases
      app_servers.values.map do |app_server|
        databases[app_server['modules-database']]
      end
    end

    def database(name)
      database = MarkLogic::Database.new(name, connection)
      database.application = self
      databases[name] = database
      yield(database) if block_given?
    end

    def app_server(name)
      app_server = MarkLogic::AppServer.new(name, @port)
      app_servers[name] = app_server
      yield(app_server) if block_given?
    end

    def config
      yield(self) if block_given?
      build_implicit_defs
    end

    def inspect
      as_nice_string = " app_name: #{app_name.inspect} port: #{port.inspect} app_servers: #{app_servers.values.each(&:inspect)}"
      "#<#{self.class}#{as_nice_string}>"
    end

    def self.load(app_name, options = {})
      app = Application.new(app_name, options)
      app.load
      app
    end

    def load
      app_servers[app_name] = MarkLogic::AppServer.load(app_name)
      @port = app_servers[app_name]['port']
      load_databases
      build_indexes
    end

    private

    def update_or_create_databases
      databases.each do |_database_name, database|
        if database.exists?
          database.update
        else
          database.create
        end
      end
    end

    def create_forests
      forests.each do |_forest_name, forest|
        forest.create unless forest.exists?
      end
    end

    def update_or_create_app_servers
      app_servers.each do |_server_name, app_server|
        if app_server.exists?
          app_server.update
        else
          app_server.create
        end
      end
    end

    def load_database(db_name)
      db = MarkLogic::Database.load(db_name, connection)
      db.application = self
      databases[db_name] = db

      db['forest'].each do |forest_name|
        forests[forest_name] = MarkLogic::Forest.load(forest_name, nil, connection) unless forests.key?(forest_name)
        forests[forest_name].database = db
      end
    end

    def load_databases
      app_servers.each_value do |app_server|
        load_if_needed(app_server['content-database'])
        load_if_needed(app_server['modules-database'])
      end

      triggers_database, schema_database = trigger_and_schema_names
      load_if_needed(triggers_database)
      load_if_needed(schema_database)
    end

    def load_if_needed(key)
      load_database(key) if load_needed?(key)
    end

    def load_needed?(key)
      key && !databases.key?(key)
    end

    def trigger_and_schema_names
      triggers_database = nil
      schema_database = nil
      databases.each_value do |database|
        if database.key?('triggers-database')
          triggers_database = database['triggers-database']
        end

        if database.key?('schema-database')
          schema_database = database['schema-database']
        end
      end
      [triggers_database, schema_database]
    end

    def indexes
      @indexes ||= {}
    end

    def build_implicit_defs
      build_appservers
      build_databases
      build_indexes
    end

    def build_appservers
      return unless app_servers.empty?
      app_servers[@app_name] = MarkLogic::AppServer.new(@app_name, @port, 'http', 'Default', connection: connection, admin_connection: admin_connection)
    end

    def build_databases
      app_servers.each_value do |app_server|
        db_name = app_server['content-database']
        build_db_if_needed(db_name)
        new_forest(db_name)

        modules_db_name = app_server['modules-database']
        build_module_db_if_needed(modules_db_name)
        new_forest(modules_db_name)
      end

      build_trigger_schema_databases
    end

    def new_forest(key)
      forests[key] = MarkLogic::Forest.new(key, nil, connection) unless forests.key?(key)
      forests[key].database = databases[key]
    end

    def build_db_if_needed(db_name)
      return if db_name.nil? || databases.key?(db_name)

      db = MarkLogic::Database.new(db_name, connection)
      db.application = self
      databases[db_name] = db
    end

    def build_module_db_if_needed(modules_db_name)
      return if databases.key?(modules_db_name)
      modules_db = MarkLogic::Database.new(modules_db_name, connection)
      modules_db.application = self
      databases[modules_db_name] = modules_db
    end

    def build_trigger_schema_databases
      triggers_database, schema_database = trigger_and_schema_names
      build_db_if_needed(triggers_database)
      build_db_if_needed(schema_database)
    end

    def build_indexes
      content_databases.each do |database|
        database.reset_indexes

        indexes.clone.each do |_key, index|
          index.append_to_db(database)
        end
      end
    end
  end
end
