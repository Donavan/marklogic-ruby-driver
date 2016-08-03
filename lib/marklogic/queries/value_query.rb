module MarkLogic
  module Queries
    class ValueQuery < BaseQuery
      def initialize(name, value, options = {})
        @name = name.to_s
        @value = value
        @value = value.to_s if value.is_a?(ObjectId)
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
        @options[:exact] = true if @options.length.zero?
      end

      attr_writer :options

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.tr('_', '-')
          case k.to_s
          when 'lang', 'min_occurs', 'max_occurs'
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
        value = query_value(@value)
        %{cts:json-property-value-query("#{@name}",(#{value}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
