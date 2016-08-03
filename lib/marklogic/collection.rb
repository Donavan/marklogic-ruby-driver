require 'securerandom'

module MarkLogic
  # A Marklogic Collection.  See: https://docs.marklogic.com/guide/search-dev/collections
  class Collection
    attr_accessor :collection
    attr_reader :database

    alias name collection
    def initialize(name, database)
      @collection = name
      @database = database
      @operators = %w(GT LT GE LE EQ NE ASC DESC)
    end

    def count
      MarkLogic::Cursor.new(self).count
    end

    def load(id)
      url = "/v1/documents?uri=#{gen_uri(id)}&format=json"
      response = @database.connection.get(url)
      raise Exception, "Invalid response: #{response.code.to_i}, #{response.body}" unless response.code.to_i == 200
      Oj.load(response.body)
    end

    def save(doc)
      if doc.is_a?(Array)
        save_array(doc)
      else
        save_non_array(doc)
      end
    end

    def save_non_array(doc)
      uri = doc_uri(doc)
      url = "/v1/documents?uri=#{uri}&format=json&collection=#{collection}"
      json = ::Oj.dump(doc, mode: :compat)
      response = @database.connection.put(url, json)
      raise Exception, "Invalid response: #{response.code.to_i}, #{response.body}\n" unless [201, 204].include? response.code.to_i
      doc_id(doc)
    end

    def doc_id(doc)
      doc[:_id] || doc[:id] || doc['_id'] || doc['id']
    end

    def save_array(doc)
      docs = {}
      doc.each do |d|
        docs[doc_uri(d)] = ::Oj.dump(d, mode: :compat)
      end
      body = build_multipart_body(docs)
      response = @database.connection.post_multipart('/v1/documents', body)
      raise Exception, "Invalid response: #{response.code.to_i}, #{response.body}\n" unless response.code.to_i == 200
    end

    def update(selector, document, _opts = {})
      find(selector).each do |doc|
        document.each do |key, value|
          operation = key.downcase.gsub('$', 'update_op_')
          send(operation, doc, value)
          save(doc)
        end
      end
    end

    alias create save
    alias insert save

    # rubocop:disable Metrics/AbcSize
    def remove(query = nil, _options = {})
      return drop if should_drop_on_remove?(query)
      query = from_criteria(query) if query.class == Hash
      query ||= Queries::AndQuery.new
      xqy = %{cts:search(fn:collection("#{collection}"), #{query}, ("unfiltered")) / xdmp:node-delete(.)}
      response = @database.connection.run_query(xqy, 'xquery')
      raise Exception, "Invalid response: #{response.code.to_i}, #{response.body}" unless response.code.to_i == 200
    end
    # rubocop:enable Metrics/AbcSize

    def drop
      url = "/v1/search?collection=#{collection}"
      response = @database.connection.delete(url)
      raise Exception, "Invalid response: #{response.code.to_i}, #{response.body}" unless [204].include? response.code.to_i
    end

    def find_one(query = nil, options = {})
      opts = options.merge(per_page: 1)
      find(query, opts).next
    end

    def find(query = nil, options = {})
      if query.class == Hash
        query = from_criteria(query)
      elsif query.nil?
        query = Queries::AndQuery.new
      end
      options[:query] = query
      cursor = MarkLogic::Cursor.new(self, options)

      if block_given?
        yield cursor
        nil
      else
        cursor
      end
    end

    def build_query(name, operator, value, query_options = {})
      return build_range_query(name, operator, value, query_options) if should_build_range_query?(name, query_options)
      raise MissingIndexError, "Missing index on #{name}" if operator != 'EQ'

      if value.nil?
        Queries::OrQuery.new([Queries::ValueQuery.new(name, value, query_options),
                              Queries::NotQuery.new(Queries::ContainerQuery.new(name, Queries::AndQuery.new))])
      else
        Queries::ValueQuery.new(name, value, query_options)
      end
    end

    # Builds a MarkLogic Query from Mongo Style Criteria
    #
    # @param [Hash] criteria The Criteria to use when searching
    #
    # @example Build a query from criteria
    #
    #    # Query on age == 3
    #    collection.from_criteria({ 'age' => { '$eq' =>  3  } })
    #
    #    # Query on age < 3
    #    collection.from_criteria({ 'age' => { '$lt' =>  3  } })
    #
    #    # Query on age <= 3
    #    collection.from_criteria({ 'age' => { '$le' =>  3  } })
    #
    #    # Query on age > 3
    #    collection.from_criteria({ 'age' => { '$gt' =>  3  } })
    #
    #    # Query on age >= 3
    #    collection.from_criteria({ 'age' => { '$ge' =>  3  } })
    #
    #    # Query on age != 3
    #    collection.from_criteria({ 'age' => { '$ne' =>  3  } })
    #
    # @since 0.0.1
    def from_criteria(criteria)
      queries = []

      criteria.each do |k, v|
        query_options = {}
        queries << (v.is_a?(Hash) ? criteria_from_hash(k.to_s, v) : build_query(k.to_s, 'EQ', v, query_options))
      end

      if queries.length > 1
        MarkLogic::Queries::AndQuery.new(*queries)
      elsif queries.length == 1
        queries[0]
      end
    end

    def to_s
      %(collection: #{collection})
    end

    def inspect
      as_nice_string = [
        " collection: #{collection.inspect}",
        " database: #{database.database_name.inspect}"
      ].join(',')
      "#<#{self.class}#{as_nice_string}>"
    end

    private

    def criteria_from_hash(name, criteria_hash)
      query_options = {}
      query_options.merge!(criteria_hash.delete(:options) || {})

      sub_queries = []
      criteria_hash.each do |kk, vv|
        operator = kk.to_s.delete('$').upcase || 'EQ'
        sub_queries << sub_query_from_hash(name, operator, vv, query_options)
      end

      return Queries::AndQuery.new(sub_queries) if sub_queries.length > 1
      return sub_queries[0] if sub_queries.length == 1
      nil
    end

    def sub_query_from_hash(name, operator, value, query_options)
      if @operators.include?(operator)
        value = value.to_s if value.is_a?(MarkLogic::ObjectId)
        build_query(name, operator, value, query_options)
      elsif value.is_a?(Hash)
        child_queries = value.map do |kk, vv|
          build_query(kk, vv, query_options)
        end

        Queries::ContainerQuery.new(name, Queries::AndQuery.new(child_queries))
      end
    end

    def doc_uri(doc)
      id = doc[:_id] || doc['_id']
      if id.nil?
        id = SecureRandom.hex
        doc[:_id] = id
      end
      gen_uri(id)
    end

    def gen_uri(id)
      id_str = if id.is_a?(Hash)
                 id.hash.to_s
               else
                 id.to_s
               end
      %(/#{collection}/#{id_str}.json)
    end

    def build_multipart_body(docs, boundary = 'BOUNDARY')
      tmp = ''

      # collection
      metadata = ::Oj.dump({ collections: [collection] }, mode: :compat)
      tmp << multipart_header(metadata, boundary)

      docs.each do |uri, doc|
        # doc
        tmp << multipart_doc(uri, doc, boundary)
      end
      tmp << "--#{boundary}--"
    end

    def multipart_doc(uri, doc, boundary)
      tmp = ''
      tmp << %(--#{boundary}\r\n)
      tmp << %(Content-Type: application/json\r\n)
      tmp << %(Content-Disposition: attachment; filename="#{uri}"; category=content; format=json\r\n)
      tmp << %(Content-Length: #{doc.size}\r\n\r\n)
      tmp << doc
      tmp << %(\r\n)
    end

    def multipart_header(metadata, boundary = 'BOUNDARY')
      tmp = ''
      tmp << %(--#{boundary}\r\n)
      tmp << %(Content-Type: application/json\r\n)
      tmp << %(Content-Disposition: inline; category=metadata\r\n)
      tmp << %(Content-Length: #{metadata.size}\r\n\r\n)
      tmp << metadata
      tmp << %(\r\n)
    end

    def update_op_set(doc, value)
      value.each do |kk, vv|
        doc[kk.to_s] = vv
      end
    end

    def update_op_inc(doc, value)
      value.each do |kk, vv|
        prev = doc[kk.to_s] || 0
        doc[kk.to_s] = prev + vv
      end
    end

    def update_op_unset(doc, value)
      value.keys.each do |kk|
        doc.delete(kk.to_s)
      end
    end

    def update_op_push(doc, value)
      value.each do |kk, vv|
        if doc.key?(kk.to_s)
          doc[kk.to_s].push(vv)
        else
          doc[kk.to_s] = [vv]
        end
      end
    end

    def update_op_pushall(doc, value)
      value.each do |kk, vv|
        doc[kk.to_s] = doc.key?(kk.to_s) ? (doc[kk.to_s] + vv) : vv
      end
    end

    def should_drop_on_remove?(query)
      query.nil? || (query.is_a?(Hash) && query.empty?)
    end

    def should_build_range_query?(name, query_options = {})
      database.has_range_index?(name) && case_insensitive?(query_options)
    end

    def build_range_query(name, operator, value, query_options = {})
      index = database.range_index(name)
      type = index.scalar_type
      Queries::RangeQuery.new(name, operator, type, value, query_options)
    end

    def case_insensitive?(query_options)
      (query_options.key?(:case_sensitive) == false || query_options[:case_sensitive] == true)
    end
  end
end
