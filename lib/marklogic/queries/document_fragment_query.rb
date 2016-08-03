module MarkLogic
  module Queries
    class DocumentFragmentQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %{cts:document-fragment-query(#{@query})}
      end
    end
  end
end
