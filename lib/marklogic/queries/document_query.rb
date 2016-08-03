module MarkLogic
  module Queries
    class DocumentQuery < BaseQuery
      def initialize(uris)
        @uris = uris
      end

      def to_s
        uris = query_value(@uris)
        %{cts:document-query((#{uris}))}
      end
    end
  end
end
