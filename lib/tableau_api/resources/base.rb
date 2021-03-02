# frozen_string_literal: true

module TableauApi
  module Resources
    class Base
      def initialize(client)
        @client = client
      end
    end
  end
end
