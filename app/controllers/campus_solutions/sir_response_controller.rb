module CampusSolutions
  class SirResponseController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MySirResponse
    end

  end
end
