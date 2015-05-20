module CampusSolutions
  class Budget < IntegrationHubProxy

    def initialize(options = {})
      super(Settings.cs_budget_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'cs_budget.xml'
    end

  end
end
