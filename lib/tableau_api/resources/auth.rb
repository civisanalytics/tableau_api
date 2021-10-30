module TableauApi
  module Resources
    class Auth < Base
      def token
        sign_in unless signed_in?
        @token
      end

      def site_id
        sign_in unless signed_in?
        @site_id
      end

      def user_id
        sign_in unless signed_in?
        @user_id
      end

      def sign_in
        return true if signed_in?

        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.credentials(authentication_credentials) do |cred|
            cred.site(contentUrl: @client.site_name == 'Default' ? '' : @client.site_name)
          end
        end

        res = @client.connection.api_post('auth/signin', body: request)

        return false unless res.code == 200

        @token = res['tsResponse']['credentials']['token']
        @site_id = res['tsResponse']['credentials']['site']['id']
        @user_id = res['tsResponse']['credentials']['user']['id']

        true
      end

      def signed_in?
        !@token.nil?
      end

      def sign_out
        return true unless signed_in?

        res = @client.connection.api_post('auth/signout', body: nil)

        # consider 401 to be successful since signing out with an expired
        # token fails, but we can still consider the user signed out
        return false unless res.code == 204 || res.code == 401

        @token = nil
        @site_id = nil
        @user_id = nil

        true
      end

      def trusted_ticket
        body = {
          username: @client.username,
          target_site: @client.site_name == 'Default' ? '' : @client.site_name
        }

        begin
          res = @client.connection.post('trusted', body: body, limit: 1)
        rescue HTTParty::RedirectionTooDeep
          # redirects if the site_name is invalid
          res = false
        end

        return unless res && res.code == 200 && res.body != '-1'

        res.body
      end

      private

      def authentication_credentials
        if @client.authentication_type == Client::AUTH_TYPE_PERSONAL_ACCESS_TOKEN
          {
            personalAccessTokenName: @client.personal_access_token_name,
            personalAccessTokenSecret: @client.personal_access_token_secret
          }
        else
          { name: @client.username, password: @client.password }
        end
      end
    end
  end
end
