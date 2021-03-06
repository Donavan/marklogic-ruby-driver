module MarkLogic
  module Queries
    class DocumentFragmentQuery < BaseQuery
      def initialize(query)
        @query = query
      end

      def to_s
        %Q{cts:document-fragment-query(#{@query})}
      end
    end
  end
end
