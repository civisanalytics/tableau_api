module TableauApi
  module Resources
    class Sites < Base
      def list
        @client.connection.api_get_collection('sites', 'sites.site')
      end

      def create(name:, content_url:, admin_mode: nil, num_users: nil, storage_quota: nil)
        # required parameters
        request_hash = {
          name: name,
          contentUrl: content_url
        }
        # optional parameters
        request_hash[:admin_mode] = admin_mode if admin_mode
        request_hash[:num_users] = num_users if num_users
        request_hash[:storage_quota] = storage_quota if storage_quota

        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.site(request_hash)
        end

        res = @client.connection.api_post('sites', body: request)

        return res['tsResponse']['site'] if res.code == 201
        raise TableauError, res
      end

      def delete(site_id:)
        res = @client.connection.api_delete("sites/#{site_id}")
        return true if res.code == 204
        raise TableauError, res
      end

      def views(site_id, fields = [])
        query = {}
        query[:fields] = fields.join(',') if fields.present?
        @client.connection.api_get_collection(
          "sites/#{site_id}/views", 'views.view', query: query
        )
      end
    end
  end
end
