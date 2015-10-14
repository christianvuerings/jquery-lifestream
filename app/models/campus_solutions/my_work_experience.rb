module CampusSolutions
  class MyWorkExperience < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::WorkExperience.new({user_id: @uid, params: params})
      PersonDataExpiry.expire @uid
      proxy.get
    end

  end
end
