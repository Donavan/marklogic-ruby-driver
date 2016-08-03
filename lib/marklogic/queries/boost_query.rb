module MarkLogic
  module Queries
    # See: https://docs.marklogic.com/cts:boost-query
    class BoostQuery < BaseQuery
      def initialize(matching_query, boosting_query)
        @matching_query = matching_query
        @boosting_query = boosting_query
      end

      def to_s
        %{cts:boost-query(#{@matching_query},#{@boosting_query})}
      end
    end
  end
end
