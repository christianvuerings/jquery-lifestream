module CampusSolutions
  class EthnicityController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyEthnicity
    end

    def delete
      delete_passthrough CampusSolutions::MyEthnicity
    end

  end
end
