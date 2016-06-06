require 'zip'

module TableauApi
  module Resources
    class Workbooks < Base
      def version(file)
        version = nil

        if File.exist?(file) && File.extname(file) == '.twbx'
          Zip::File.open(file) do |zip_file|
            entry = zip_file.glob('*.twb').first
            version = HTTParty::Parser.new(entry.get_input_stream.read, :xml).parse['workbook']['version']
          end
        end

        version
      end

      # rubocop:disable Metrics/ParameterLists
      def publish(name:, project_id:, file:, overwrite: false, show_tabs: false, connection_username: nil, connection_password: nil, connection_embed: false)
        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.workbook(name: name, showTabs: show_tabs) do |wb|
            wb.project(id: project_id)
            wb.connectionCredentials(name: connection_username, password: connection_password, embed: connection_embed) if connection_username
          end
        end

        query = URI.encode_www_form([['overwrite', overwrite]])
        path = "sites/#{@client.auth.site_id}/workbooks?#{query}"

        parts = {
          'request_payload' => request,
          'tableau_workbook' => UploadIO.new(file, 'application/octet-stream')
        }

        headers = {
          parts: {
            'request_payload' => { 'Content-Type' => 'text/xml' },
            'tableau_workbook' => { 'Content-Type' => 'application/octet-string' }
          }
        }

        res = @client.connection.api_post_multipart(path, parts, headers)

        return HTTParty::Parser.new(res.body, :xml).parse['tsResponse']['workbook'] if res.code == '201'

        raise TableauError, res
      end
      # rubocop:enable Metrics/ParameterLists

      CAPABILITIES = %w(
        AddComment ChangeHierarchy ChangePermissions Delete ExportData ExportImage ExportXml
        Filter Read ShareView ViewComments ViewUnderlyingData WebAuthoring Write
      ).freeze

      # capabilities is a hash of symbol keys to booleans { Read: true, ChangePermissions: false }
      def permissions(workbook_id:, user_id:, capabilities:)
        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.permissions do |p|
            p.workbook(id: workbook_id)
            p.granteeCapabilities do |gc|
              gc.user(id: user_id)
              gc.capabilities do |c|
                capabilities.each do |k, v|
                  k = k.to_s
                  raise "invalid capability #{k}" unless CAPABILITIES.include? k
                  c.capability(name: k, mode: v ? 'Allow' : 'Deny')
                end
              end
            end
          end
        end

        res = @client.connection.api_put("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/permissions", body: request)

        res.code == 200
      end

      def update(workbook_id:, owner_user_id:)
        request = Builder::XmlMarkup.new.tsRequest do |ts|
          ts.workbook(id: workbook_id) do |w|
            w.owner(id: owner_user_id)
          end
        end

        res = @client.connection.api_put("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}", body: request)

        res.code == 200
      end

      def find(workbook_id)
        res = @client.connection.api_get("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}")
        res['tsResponse']['workbook'] if res.code == 200
      end

      def views(workbook_id)
        url = "sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/views"
        @client.connection.api_get_collection(url, 'views.view')
      end

      def list
        url = "sites/#{@client.auth.site_id}/users/#{@client.auth.user_id}/workbooks"
        @client.connection.api_get_collection(url, 'workbooks.workbook')
      end
    end
  end
end
