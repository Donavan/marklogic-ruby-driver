module MarkLogic
  module Queries
    class PropertiesFragmentQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %{cts:properties-fragment-query(#{@query})}
      end
    end
  end
end
