# frozen_string_literal: true

module TableauApi
  module Resources
    class Datasources < Base
      def list
        url = "sites/#{@client.auth.site_id}/datasources"
        @client.connection.api_get_collection(url, 'datasources.datasource')
      end
    end
  end
end
