module TableauApi
  class Connection
    API_VERSION = '2.8'.freeze

    include HTTParty

    def initialize(client)
      @client = client
    end

    def post(path, *args)
      self.class.post("#{@client.host}/#{path}", *args)
    end

    # if the result is paginated, it will fetch subsequent pages
    # collection can be delimited with a period to do nested hash lookups
    # e.g. objects.object
    def api_get_collection(path, collection, *args)
      Enumerator.new do |enum|
        args[0] = {} unless args[0]
        page_size = (args[0].delete(:page_size) { 100 }).to_i
        page_number = (args[0].delete(:page_number) { 1 }).to_i

        loop do
          uri = URI::HTTP.build(path: "/#{path}", query: URI.encode_www_form(pageSize: page_size, pageNumber: page_number)).request_uri

          res = api_get(uri, *args)
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

    def api_get(path, *args)
      api_method(:get, path, *args)
    end

    def api_post(path, *args)
      args[0][:headers] = {} unless args[0][:headers]
      args[0][:headers]['Content-Type'] = 'application/xml'
      api_method(:post, path, *args)
    end

    def api_put(path, *args)
      args[0][:headers] = {} unless args[0][:headers]
      args[0][:headers]['Content-Type'] = 'application/xml'
      api_method(:put, path, *args)
    end

    def api_delete(path, *args)
      api_method(:delete, path, *args)
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

    def api_method(method, path, *args)
      # do not attach auth headers or attempt to signin if we're signing in
      unless path == 'auth/signin'
        args[0] = {} unless args[0]
        args[0][:headers] = {} unless args[0][:headers]
        args[0][:headers].merge!(auth_headers)
      end
      self.class.send(method, url_for(path), *args)
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
