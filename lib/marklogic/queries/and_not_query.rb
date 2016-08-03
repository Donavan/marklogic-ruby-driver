module MarkLogic
  module Queries
    class AndNotQuery < BaseQuery
      def initialize(positive_query, negative_query)
        @positive_query = positive_query
        @negative_query = negative_query
      end

      def to_s
        %Q{cts:and-not-query(#{@positive_query},#{@negative_query})}
      end
    end
  end
end
