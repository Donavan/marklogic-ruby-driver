module MarkLogic
  module Queries
    class ContainerQuery< BaseQuery
      def initialize(name, query, options = {})
        @name = name
        @query = query
        @options = options
      end

      def to_s
        %Q{cts:json-property-scope-query("#{@name}",#{@query})}
      end
    end
  end
end
