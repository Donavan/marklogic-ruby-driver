module MarkLogic
  module Queries
    # See: https://docs.marklogic.com/cts:and-not-query
    class AndNotQuery < BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_s
        %{cts:and-not-query(#{@positive_query},#{@negative_query})}
      end
    end
  end
end
