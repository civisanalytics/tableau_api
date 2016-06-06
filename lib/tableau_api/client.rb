module TableauApi
  class Client
    attr_reader :host, :username, :password, :site_id, :site_name

    def initialize(host:, site_name:, username:, password: nil)
      @resources = {}

      raise 'host is required' if host.to_s.empty?
      @host = host

      raise 'site_name is required' if site_name.to_s.empty?
      @site_name = site_name

      raise 'username is required' if username.to_s.empty?
      @username = username

      @password = password
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
        workbooks: TableauApi::Resources::Workbooks
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
  end
end
