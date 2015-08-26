module CampusSolutions
  class EmergencyContactController < CampusSolutionsController

    def post
      post_passthrough CampusSolutions::MyEmergencyContact
    end

  end
end
