module CampusSolutions
  class PersonNameController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyPersonName
    end

    def delete
      delete_passthrough CampusSolutions::MyPersonName
    end

  end
end
