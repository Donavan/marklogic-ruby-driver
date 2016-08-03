module MarkLogic
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

      databases.each do |_database_name, database|
        if database.exists?
          database.update
        else
          database.create
        end
      end

      forests.each do |_forest_name, forest|
        forest.create unless forest.exists?
      end

      app_servers.each do |_server_name, app_server|
        if app_server.exists?
          app_server.update
        else
          app_server.create
        end
      end
    end

    def create_indexes
      build_implicit_defs

      content_databases.each do |database|
        if database.exists?
          database.update
        else
          database.create
        end
      end
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

      databases.each do |database_name, database|
        unless database.exists?
          logger.debug "database: #{database_name} is missing"
          return true
        end
      end

      content_databases.each do |database|
        if database.stale?
          logger.debug "database: #{database.database_name} is stale"
          return true
        end
      end

      forests.each do |forest_name, forest|
        unless forest.exists?
          logger.debug "forest: #{forest_name} is missing"
          return true
        end
      end

      app_servers.each do |server_name, app_server|
        unless app_server.exists?
          logger.debug "app_server: #{server_name} is missing"
          return true
        end
      end

      false
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
      as_nice_string = [
        " app_name: #{app_name.inspect}",
        " port: #{port.inspect}",
        " app_servers: #{app_servers.values.each(&:inspect)}"
      ].join(',')
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
        db_name = app_server['content-database']
        load_database(db_name) unless databases.key?(db_name)

        modules_db_name = app_server['modules-database']
        load_database(modules_db_name) unless databases.key?(modules_db_name)
      end

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

      if triggers_database && !databases.key?(triggers_database)
        load_database(triggers_database)
        # databases[triggers_database] = MarkLogic::Database.new(triggers_database, self.connection)
      end

      if schema_database && !databases.key?(schema_database)
        load_database(schema_database)
        # databases[schema_database] = MarkLogic::Database.new(schema_database, self.connection)
      end
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
      if app_servers.empty?
        app_servers[@app_name] = MarkLogic::AppServer.new(@app_name, @port, 'http', 'Default', connection: connection, admin_connection: admin_connection)
      end
    end

    def build_databases
      app_servers.each_value do |app_server|
        db_name = app_server['content-database']
        unless databases.key?(db_name)
          db = MarkLogic::Database.new(db_name, connection)
          db.application = self
          databases[db_name] = db
        end
        forests[db_name] = MarkLogic::Forest.new(db_name, nil, connection) unless forests.key?(db_name)
        forests[db_name].database = databases[db_name]

        modules_db_name = app_server['modules-database']
        unless databases.key?(modules_db_name)
          modules_db = MarkLogic::Database.new(modules_db_name, connection)
          modules_db.application = self
          databases[modules_db_name] = modules_db
        end
        forests[modules_db_name] = MarkLogic::Forest.new(modules_db_name, nil, connection) unless forests.key?(modules_db_name)
        forests[modules_db_name].database = databases[modules_db_name]
      end

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

      if triggers_database && !databases.key?(triggers_database)
        databases[triggers_database] = MarkLogic::Database.new(triggers_database, connection)
      end

      if schema_database && !databases.key?(schema_database)
        databases[schema_database] = MarkLogic::Database.new(schema_database, connection)
      end
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
