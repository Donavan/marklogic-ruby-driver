module MarkLogic
  module Queries
    class BaseQuery
      alias to_xqy to_s
      #
      # @param [ String ] response A string containing the response from the MarkLogic server to a query
      # @param [ Hash ] opts Options for
      #
      def format_response(response, opts = {})
        to_xml(response, opts)
      end

      # Helper function to add a sub query into a parent query
      #
      # @param [ BaseQuery ] parent The parent query
      # @param [ BaseQuery ] query The sub-query to add
      #
      # @since 1.0.0
      def add_sub_query(parent, query)
        query_json = query.to_json
        query_key = query_json.keys[0]
        parent[query_key] = query_json[query_key]
      end

      # Returns the value of the query appropriately formatted
      #
      # @param [ Any ] original_value The value to format
      # @param [ String ] type The data type
      #
      # @since 1.0.0
      def query_value(original_value, type = nil)
        value = if original_value.is_a?(Array)
                  original_value.map { |v| query_value(v) }.join(',')
                elsif original_value.is_a?(TrueClass)
                  'fn:true()'
                elsif original_value.is_a?(FalseClass)
                  'fn:false()'
                elsif original_value.is_a?(ObjectId)
                  %("#{original_value}")
                elsif original_value.is_a?(String) || type == 'string'
                  %("#{original_value}")
                else
                  original_value
                end
      end

      private

      def to_xml(response, opts)
        return array_to_xml(response, opts) if response.class == Array

        xml_proc = options.fetch(:to_xml) { proc { |xml| ::Nokogiri::XML(xml) } }
        xml = xml_proc.call(response)
        xml.remove_namespaces! if opts[:strip_namespace]
        opts[:at_xpath] ? xml.at_xpath(opts[:at_xpath]) : xml
      end

      def array_to_xml(response, opts)
        if opts[:want_array]
          response.map { |resp| to_xml(resp, opts) }
        else
          to_xml(response[opts.fetch(:want_index, 0).to_i], opts)
        end
      end
    end
  end
end
