module MarkLogic
  module Queries
    class WordQuery < BaseQuery
      def initialize(values, options = {})
        @values = values
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
        @options[:exact] = true if @options.length.zero?
      end

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.tr('_', '-')
          case k.to_s
          when 'lang', 'distance_weight', 'min_occurs', 'max_occurs', 'lexicon_expand'
            opts << %("#{dashed_key}=#{v}")
          when /(case|diacritic|punctuation|whitespace)_sensitive/
            opts << (v == true ? %("#{Regexp.last_match(1)}-sensitive") : %("#{Regexp.last_match(1)}-insensitive"))
          when 'exact'
            opts << %("#{dashed_key}")
          when 'stemmed', 'wildcarded'
            opts << (v == true ? %("#{dashed_key}") : %("un#{dashed_key}"))
          else
            opts << %("#{v}")
          end
        end

        opts
      end

      def to_s
        values = query_value(@values)
        %{cts:word-query((#{values}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
