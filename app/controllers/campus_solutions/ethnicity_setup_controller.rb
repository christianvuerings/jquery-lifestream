module CampusSolutions
  class EthnicitySetupController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::EthnicitySetup
    end

  end
end
