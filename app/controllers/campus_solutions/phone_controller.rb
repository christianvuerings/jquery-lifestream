module CampusSolutions
  class PhoneController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyPhone
    end

    def delete
      delete_passthrough CampusSolutions::MyPhone
    end

  end
end
