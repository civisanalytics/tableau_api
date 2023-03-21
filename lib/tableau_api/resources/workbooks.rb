# frozen_string_literal: true

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

      CAPABILITIES = %w[
        AddComment ChangeHierarchy ChangePermissions CreateRefreshMetrics Delete ExportData ExportImage
        ExportXml Filter Read RunExplainData ShareView ViewComments ViewUnderlyingData WebAuthoring Write
      ].freeze

      CAPABILITY_MODES = %w[ALLOW DENY].freeze

      # rubocop:disable Metrics/CyclomaticComplexity
      def permissions(workbook_id:)
        res = @client.connection.api_get("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/permissions")

        raise TableauError, res if res.code != 200

        permissions = HTTParty::Parser.new(res.body, :xml).parse['tsResponse']['permissions']['granteeCapabilities']
        return [] if permissions.nil?

        permissions = [permissions] unless permissions.is_a? Array
        permissions.map do |p|
          grantee_type = p['group'].nil? ? 'user' : 'group'

          capabilities = {}
          capabilities_list = p['capabilities']['capability']
          capabilities_list = [capabilities_list] unless capabilities_list.is_a? Array

          capabilities_list.each do |c|
            capabilities[c['name'].to_sym] = c['mode'] == 'Allow'
          end

          {
            grantee_type: grantee_type,
            grantee_id: p[grantee_type]['id'],
            capabilities: capabilities
          }
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # capabilities is a hash of symbol keys to booleans { Read: true, ChangePermissions: false }
      def add_permissions(workbook_id:, capabilities:, user_id: nil, group_id: nil)
        validate_user_group_exclusivity(user_id, group_id)

        request = permissions_request(workbook_id, user_id, group_id, capabilities)
        res = @client.connection.api_put("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/permissions", body: request)

        res.code == 200
      end

      def delete_permissions(workbook_id:, capability:, capability_mode:, user_id: nil, group_id: nil)
        validate_user_group_exclusivity(user_id, group_id)
        raise 'invalid capability' unless CAPABILITIES.include? capability.to_s
        raise 'invalid mode' unless CAPABILITY_MODES.include? capability_mode.to_s

        subpath = user_id ? "users/#{user_id}" : "groups/#{group_id}"
        subpath += "/#{capability}/#{capability_mode.capitalize}"
        res = @client.connection.api_delete("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/permissions/#{subpath}")

        res.code == 204
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

      def refresh(workbook_id:)
        request = Builder::XmlMarkup.new.tsRequest
        res = @client.connection.api_post("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/refresh", body: request)
        res.code == 202
      end

      def preview_image(workbook_id:)
        res = @client.connection.api_get("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/previewImage")
        res.body if res.code == 200
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

      private

      def permissions_request(workbook_id, user_id, group_id, capabilities)
        Builder::XmlMarkup.new.tsRequest do |ts|
          ts.permissions do |p|
            p.workbook(id: workbook_id)
            p.granteeCapabilities do |gc|
              gc.user(id: user_id) if user_id
              gc.group(id: group_id) if group_id
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
      end

      def validate_user_group_exclusivity(user_id, group_id)
        raise 'cannot specify user_id and group_id simultaneously' if user_id && group_id
        raise 'must specify user_id or group_id' unless user_id || group_id
      end
    end
  end
end
