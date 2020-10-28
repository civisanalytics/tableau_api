module TableauApi
  module Resources
    class Jobs < Base
      def list(kwargs = {})
        url = "sites/#{@client.auth.site_id}/jobs"
        @client.connection.api_get_collection(url, 'jobs.job', **kwargs)
      end
    end
  end
end
