module CampusSolutions
  class CountryController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::Country
    end

  end
end
