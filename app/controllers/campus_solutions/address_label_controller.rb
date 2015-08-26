module CampusSolutions
  class AddressLabelController < CampusSolutionsController

    def get
      json_passthrough(CampusSolutions::AddressLabel, {country: params['country']})
    end

  end
end
