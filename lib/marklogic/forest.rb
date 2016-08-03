module MarkLogic
  class Forest
    include MarkLogic::Persistence

    attr_accessor :forest_name
    def initialize(forest_name, host_name = nil, conn = nil)
      self.connection = conn
      @forest_name = forest_name
      @host_name = host_name || manage_connection.host
      @options = {
        'forest-name' => @forest_name,
        'host' => @host_name
      }
    end

    def self.load(forest_name, host_name = nil, conn = nil)
      db = Forest.new(forest_name, host_name, conn)
      db.load
      db
    end

    def load
      resp = manage_connection.get(%(/manage/v2/forests/#{forest_name}/properties?format=json))
      if resp.code.to_i == 200
        options = Oj.load(resp.body)
        options.each do |key, value|
          self[key] = value
        end
      end
    end

    def []=(key, value)
      @options[key] = value
    end

    def [](key)
      @options[key]
    end

    def has_key?(key)
      @options.key?(key)
    end

    def database=(db)
      @database = db
      @options['database'] = db.database_name
    end

    def create
      manage_connection.post_json(
        %(/manage/v2/forests?format=json),
        @options
      )
    end

    def exists?
      manage_connection.head(%(/manage/v2/forests/#{forest_name})).code.to_i == 200
    end

    def drop
      manage_connection.delete(%(/manage/v2/forests/#{forest_name}?level=full&format=json))
    end
  end
end
