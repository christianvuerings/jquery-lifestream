module CampusSolutions
  class AddressTypeController < CampusSolutionsController

    def get
      json_passthrough CampusSolutions::AddressType
    end

  end
end
