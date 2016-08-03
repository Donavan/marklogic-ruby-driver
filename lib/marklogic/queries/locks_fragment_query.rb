module MarkLogic
  module Queries
    class LocksFragmentQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %{cts:locks-fragment-query(#{@query})}
      end
    end
  end
end
