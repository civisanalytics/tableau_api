require 'httparty'
require 'builder'
require 'net/http/post/multipart'

require 'tableau_api/version'

require 'tableau_api/client'
require 'tableau_api/connection'
require 'tableau_api/error'
require 'tableau_api/resources/base'
require 'tableau_api/resources/auth'
require 'tableau_api/resources/projects'
require 'tableau_api/resources/sites'
require 'tableau_api/resources/users'
require 'tableau_api/resources/groups'
require 'tableau_api/resources/workbooks'
require 'tableau_api/resources/datasources'
require 'tableau_api/resources/jobs'

module TableauApi
  class << self
    def new(options = {})
      Client.new(**options)
    end
  end
end
