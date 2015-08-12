module CampusSolutions
  class Budget < IntegrationHubProxy

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.cs_budget_proxy, options)
      initialize_mocks if @fake
    end

    def request_options
      super.merge('year' => 2015)
    end

    def xml_filename
      'budget.xml'
    end

  end
end
