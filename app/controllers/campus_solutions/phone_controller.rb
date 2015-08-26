module CampusSolutions
  class PhoneController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyPhone
    end

  end
end
