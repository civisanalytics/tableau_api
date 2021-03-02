# frozen_string_literal: true

module TableauApi
  module Resources
    class Groups < Base
      def create(name:, default_site_role: 'Viewer')
        raise 'invalid default_site_role' unless Users::SITE_ROLES.include? default_site_role

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

      def users(group_id:)
        url = "sites/#{@client.auth.site_id}/groups/#{group_id}/users"
        @client.connection.api_get_collection(url, 'users.user')
      end

      def add_user(group_id:, user_id:)
        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.user(id: user_id)
        end

        res = @client.connection.api_post("sites/#{@client.auth.site_id}/groups/#{group_id}/users", body: request)

        res.code == 200
      end

      def remove_user(group_id:, user_id:)
        res = @client.connection.api_delete("sites/#{@client.auth.site_id}/groups/#{group_id}/users/#{user_id}")

        res.code == 204
      end
    end
  end
end
