module TableauApi
  module Resources
    class Users < Base
      SITE_ROLES = %w[
        Interactor
        Publisher
        SiteAdministrator
        Unlicensed
        UnlicensedWithPublish
        Viewer
        ViewerWithPublish
      ].freeze

      def create(username:, site_role: 'Viewer')
        raise 'invalid site_role' unless SITE_ROLES.include? site_role

        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.user(name: username, siteRole: site_role)
        end

        res = @client.connection.api_post("sites/#{@client.auth.site_id}/users", body: request)

        res['tsResponse']['user'] if res.code == 201
      end

      def list
        url = "sites/#{@client.auth.site_id}/users"
        @client.connection.api_get_collection(url, 'users.user')
      end

      def update_user(user_id:, site_role:)
        raise 'invalid site_role' unless SITE_ROLES.include? site_role

        res = @client.connection.api_get("sites/#{@client.auth.site_id}/users/#{user_id}")

        raise 'failed to find user' if res.code != 200
        user = res['tsResponse']['user']

        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.user(name: user['name'], siteRole: site_role)
        end

        res = @client.connection.api_put("sites/#{@client.auth.site_id}/users/#{user_id}", body: request)

        res['tsResponse']['user'] if res.code == 200
      end
    end
  end
end
