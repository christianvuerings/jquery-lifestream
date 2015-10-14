module CampusSolutions

  class DirectProxy < Proxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def request_options
      super.merge({
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        }
      })
    end

  end
end
