module CampusSolutions
  class SirConfig < DirectProxy

    include ProfileFeatureFlagged

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'sir_config.xml'
    end

    def url
      "#{@settings.base_url}/UC_SIR_CONFIG.v1/get/sir/config/?INSTITUTION=UCB01"
    end

  end
end
