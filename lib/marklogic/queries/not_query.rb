module MarkLogic
  module Queries
    class NotQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %{cts:not-query(#{@query})}
      end
    end
  end
end
