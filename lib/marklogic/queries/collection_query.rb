module MarkLogic
  module Queries
    # See: https://docs.marklogic.com/cts:collection-query
    class CollectionQuery < BaseQuery
      def initialize(collection_uris)
        @collection_uris = collection_uris
      end

      def to_s
        uris = query_value(@collection_uris)
        %{cts:collection-query((#{uris}))}
      end
    end
  end
end
