module TableauApi
  class Connection
    API_VERSION = '3.6'.freeze

    include HTTParty
    headers 'User-Agent' => "tableau_api/#{::TableauApi::VERSION} Ruby/#{RUBY_VERSION}"

    def initialize(client)
      @client = client
    end

    def post(path, **kwargs)
      self.class.post("#{@client.host}/#{path}", kwargs)
    end

    # if the result is paginated, it will fetch subsequent pages
    # collection can be delimited with a period to do nested hash lookups
    # e.g. objects.object
    def api_get_collection(path, collection, page_number: 1, page_size: 100, **kwargs)
      Enumerator.new do |enum|
        loop do
          query = kwargs.fetch(:query, '')
          query += '&' unless query.empty?
          query += "pageSize=#{page_size}&pageNumber=#{page_number}"
          new_kwargs = kwargs.merge(query: query)

          res = api_get(path, **new_kwargs)
          raise TableauError, res if res.code.to_s != '200'

          # ensure the result is an array because it will not be an array if there is only one element
          [collection.split('.').reduce(res['tsResponse']) { |acc, elem| acc && acc[elem] }].flatten.compact.each do |obj|
            enum.yield obj
          end

          break if res['tsResponse']['pagination'].nil?
          break if page_number >= (res['tsResponse']['pagination']['totalAvailable'].to_i / page_size.to_f).ceil

          page_number += 1
        end
      end
    end

    def api_get(path, **kwargs)
      api_method(:get, path, kwargs)
    end

    def api_post(path, **kwargs)
      new_headers = kwargs.fetch(:headers, {}).merge('Content-Type' => 'application/xml')
      api_method(:post, path, kwargs.merge(headers: new_headers))
    end

    def api_put(path, **kwargs)
      new_headers = kwargs.fetch(:headers, {}).merge('Content-Type' => 'application/xml')
      api_method(:put, path, kwargs.merge(headers: new_headers))
    end

    def api_delete(path, **kwargs)
      api_method(:delete, path, kwargs)
    end

    def api_post_multipart(path, parts, headers)
      headers = auth_headers(headers)
      headers['Content-Type'] = 'multipart/mixed'

      uri = URI.parse(url_for(path))

      req = Net::HTTP::Post::Multipart.new(uri.to_s, parts, headers)

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end
    end

    private

    def api_method(method, path, kwargs)
      # do not attach auth headers or attempt to signin if we're signing in
      unless path == 'auth/signin'
        new_headers = auth_headers(kwargs.fetch(:headers, {}))
      end
      self.class.public_send(method, url_for(path), kwargs.merge(headers: new_headers))
    end

    def url_for(path)
      "#{@client.host}/api/#{API_VERSION}#{'/' unless path[0] == '/'}#{path}"
    end

    # will attempt to signin if the token hasn't been loaded
    def auth_headers(headers = {})
      h = headers.dup
      h['X-Tableau-Auth'] = @client.auth.token
      h
    end
  end
end
