module CampusSolutions
  class AddressController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyAddress
    end

    def delete
      delete_passthrough CampusSolutions::MyAddress
    end

  end
end
