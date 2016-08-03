module MarkLogic
  module Queries
    class LocksFragmentQuery< BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %Q{cts:locks-fragment-query(#{@query})}
      end
    end
  end
end
