module CampusSolutions
  class SirResponseController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MySirResponse
    end

  end
end
