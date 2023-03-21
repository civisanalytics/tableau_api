# frozen_string_literal: true

module TableauApi
  module Resources
    class Projects < Base
      def create(name:, description: '')
        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.project(name: name, description: description)
        end

        res = @client.connection.api_post("sites/#{@client.auth.site_id}/projects", body: request)

        res['tsResponse']['project'] if res.code == 201
      end

      def list
        url = "sites/#{@client.auth.site_id}/projects"
        @client.connection.api_get_collection(url, 'projects.project')
      end
    end
  end
end
