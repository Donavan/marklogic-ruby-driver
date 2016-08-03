module MarkLogic
  module Queries
    # This query will return the number of records for a sub query, if no sub query is given it will return the number
    # of records in the database
    class RecordEstimateQuery < BaseQuery
      def initialize(sub_query = 'fn:doc()')
        @sub_query = sub_query
      end

      def format_response(response, _opts = {})
        response.to_i
      end

      def to_s
        %{xdmp:estimate(#{@sub_query})}
      end
    end
  end
end
