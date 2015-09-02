module CampusSolutions
  class AddressController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyAddress
    end

    def delete
      delete_passthrough CampusSolutions::MyAddress
    end

  end
end
