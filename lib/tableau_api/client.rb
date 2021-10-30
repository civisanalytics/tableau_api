module TableauApi
  class Client
    AUTH_TYPE_PERSONAL_ACCESS_TOKEN = :personal_access_token_name
    AUTH_TYPE_USERNAME_AND_PASSWORD = :username_and_password
    AUTH_TYPE_TRUSTED_TICKET = :trusted_ticket

    attr_reader :host,
                :username,
                :password,
                :site_id,
                :site_name,
                :personal_access_token_name,
                :personal_access_token_secret

    # rubocop:disable Metrics/ParameterLists
    def initialize(host:, site_name:, username: nil, password: nil, personal_access_token_name: nil, personal_access_token_secret: nil)
      @resources = {}

      raise 'host is required' if host.to_s.empty?
      @host = host

      raise 'site_name is required' if site_name.to_s.empty?
      @site_name = site_name

      raise 'username or personal_access_token_name is required' if personal_access_token_name.to_s.empty? && username.to_s.empty?
      @personal_access_token_name = personal_access_token_name
      @username = username

      @password = password
      @personal_access_token_secret = personal_access_token_secret
    end
    # rubocop:enable Metrics/ParameterLists

    def authentication_type
      return AUTH_TYPE_PERSONAL_ACCESS_TOKEN unless @personal_access_token_name.to_s.empty?
      return AUTH_TYPE_TRUSTED_TICKET if @password.to_s.empty?

      AUTH_TYPE_USERNAME_AND_PASSWORD
    end

    def connection
      @connection ||= Connection.new(self)
    end

    def self.resources
      {
        auth: TableauApi::Resources::Auth,
        projects: TableauApi::Resources::Projects,
        sites: TableauApi::Resources::Sites,
        users: TableauApi::Resources::Users,
        groups: TableauApi::Resources::Groups,
        workbooks: TableauApi::Resources::Workbooks,
        datasources: TableauApi::Resources::Datasources,
        jobs: TableauApi::Resources::Jobs
      }
    end

    def method_missing(name, *args, &block)
      if self.class.resources.keys.include?(name)
        @resources[name] ||= self.class.resources[name].new(self)
        @resources[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      self.class.resources.keys.include?(name) || super
    end
  end
end
