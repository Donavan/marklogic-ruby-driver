module MarkLogic
  module Queries
    class GeospatialQuery < BaseQuery
      def initialize(name, regions, options = {})
        @name = name
        @regions = regions
        @options = options || {}
        @weight = @options.delete(:weight) || 1.0
      end

      attr_writer :options

      def options
        opts = []
        @options.each do |k, v|
          dashed_key = k.to_s.tr('_', '-')
          case k.to_s
          when 'coordinate_system', 'units', 'type', 'score_function', 'slope_factor'
            opts << %("#{dashed_key}=#{v}")
          when /(boundaries)_included/
            opts << (v == true ? %("#{Regexp.last_match(1)}-included") : %("#{Regexp.last_match(1)}-excluded"))
          when /([a-z\-]+_excluded)/
            opts << %("#{dashed_key}")
          when 'cached'
            opts << (v == true ? %("cached") : %("uncached"))
          when 'zero', 'synonym'
            opts << %("#{dashed_key}")
            # else
            #   opts << %Q{"#{v}"}
          end
        end

        opts
      end

      def to_s
        regions = query_value(@regions)
        %{cts:json-property-geospatial-query("#{@name}",(#{regions}),(#{options.join(',')}),#{@weight})}
      end
    end
  end
end
