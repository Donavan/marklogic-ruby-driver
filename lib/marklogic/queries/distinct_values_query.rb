module MarkLogic
  module Queries
    class DistinctValuesQuery < BaseQuery
      def initialize(sub_query)
        @sub_query = sub_query
      end

      def to_xqy
        %{fn:distinct-values(#{@sub_query})}
      end
    end
  end
end
