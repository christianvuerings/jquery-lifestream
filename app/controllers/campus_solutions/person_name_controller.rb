module CampusSolutions
  class PersonNameController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyPersonName
    end

    def delete
      delete_passthrough CampusSolutions::MyPersonName
    end

  end
end
