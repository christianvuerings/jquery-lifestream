module CampusSolutions
  class MyEmergencyContact < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::EmergencyContact.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
