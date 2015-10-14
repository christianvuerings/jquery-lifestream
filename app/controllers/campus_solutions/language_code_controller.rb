module CampusSolutions
  class LanguageCodeController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::LanguageCode
    end

  end
end
