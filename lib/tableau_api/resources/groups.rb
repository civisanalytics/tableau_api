module TableauApi
  module Resources
    class Groups < Base
      def create(name:, default_site_role: 'Viewer')
        raise 'invalid default_site_role' unless User::SITE_ROLES.include? default_site_role

        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.group(name: name, defaultSiteRole: default_site_role)
        end

        res = @client.connection.api_post("sites/#{@client.auth.site_id}/groups", body: request)

        res['tsResponse']['group'] if res.code == 201
      end

      def list
        url = "sites/#{@client.auth.site_id}/groups"
        @client.connection.api_get_collection(url, 'groups.group')
      end
    end
  end
end
