module TableauApi
  module Resources
    class Views < Base
      def preview_image(view_id:, workbook_id:)
        @client.connection.api_get("sites/#{@client.auth.site_id}/workbooks/#{workbook_id}/views/#{view_id}/previewImage").parsed_response
      end
    end
  end
end
