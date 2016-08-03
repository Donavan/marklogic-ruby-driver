module MarkLogic
  module Queries
    class DirectoryQuery < BaseQuery
      def initialize(uris, depth = nil)
        @directory_uris = uris
        @depth = depth
      end

      def to_s
        uris = query_value(@directory_uris)

        if @depth.nil?
          %{cts:directory-query((#{uris}))}
        else
          %{cts:directory-query((#{uris}),"#{@depth}")}
        end
      end
    end
  end
end
