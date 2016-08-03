module MarkLogic
  module Queries
    class OrQuery < BaseQuery
      def initialize(*args)
        @queries = args.flat_map { |i| i }
      end

      def to_json
        {
          'or-query' => {
            'queries' => @queries.map(&:to_json)
          }
        }
      end

      def to_s
        sub_queries = @queries.map(&:to_s).join(', ')
        %{cts:or-query((#{sub_queries}))}
      end
    end
  end
end
