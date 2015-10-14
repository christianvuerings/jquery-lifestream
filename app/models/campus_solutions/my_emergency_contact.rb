module CampusSolutions
  class MyEmergencyContact < UserSpecificModel

    include PersonDataUpdatingModel

    def update(params = {})
      passthrough(CampusSolutions::EmergencyContact, params)
    end

    def delete(params = {})
      passthrough(CampusSolutions::EmergencyContactDelete, params)
    end

  end
end
