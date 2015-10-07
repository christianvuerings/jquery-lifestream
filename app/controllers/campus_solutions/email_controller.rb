module CampusSolutions
  class EmailController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyEmail
    end

    def delete
      delete_passthrough CampusSolutions::MyEmail
    end

  end
end
