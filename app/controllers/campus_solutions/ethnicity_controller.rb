module CampusSolutions
  class EthnicityController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyEthnicity
    end

    def delete
      delete_passthrough CampusSolutions::MyEthnicity
    end

  end
end
