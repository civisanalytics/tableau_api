# frozen_string_literal: true

module TableauApi
  module Resources
    class Jobs < Base
      def list(params = {})
        url = "sites/#{@client.auth.site_id}/jobs"
        @client.connection.api_get_collection(url, 'backgroundJobs.backgroundJob', **params)
      end
    end
  end
end
