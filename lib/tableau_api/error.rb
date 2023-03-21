# frozen_string_literal: true

module TableauApi
  class TableauError < StandardError
    attr_reader :http_response_code, :error_code, :summary, :detail

    def initialize(net_response)
      @http_response_code = net_response.code
      error = HTTParty::Parser.new(net_response.body, :xml).parse['tsResponse']['error']
      @error_code = error['code']
      @summary = error['summary']
      @detail = error['detail']
      super("#{error_code}: #{summary}; #{detail}")
    end
  end
end
