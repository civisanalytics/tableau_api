module TableauApi
  module Resources
    class Sites < Base
      def list
        @client.connection.api_get_collection('sites', 'sites.site')
      end
    end
  end
end
