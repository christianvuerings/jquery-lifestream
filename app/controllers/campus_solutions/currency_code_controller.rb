module CampusSolutions
  class CurrencyCodeController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::CurrencyCode
    end

  end
end
