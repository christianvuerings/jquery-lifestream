module CampusSolutions
  class EmergencyContactController < CampusSolutionsController

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::MyEmergencyContact
    end

    def delete
      delete_passthrough CampusSolutions::MyEmergencyContact
    end

  end
end
