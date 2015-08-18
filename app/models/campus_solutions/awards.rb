module CampusSolutions
  class Awards < Proxy

    include IntegrationHubProxy
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.cs_awards_proxy, options)
      initialize_mocks if @fake
    end

    def request_options
      super.merge('year' => 2015)
    end

    def xml_filename
      'awards.xml'
    end

  end
end
