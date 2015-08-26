module CampusSolutions
  class EthnicityController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::Ethnicity
    end

  end
end
