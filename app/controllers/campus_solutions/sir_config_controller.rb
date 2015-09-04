module CampusSolutions
  class SirConfigController < CampusSolutionsController

    def get
      json_passthrough(CampusSolutions::SirConfig)
    end

  end
end
