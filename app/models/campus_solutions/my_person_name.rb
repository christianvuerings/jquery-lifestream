module CampusSolutions
  class MyPersonName < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::PersonName.new({user_id: @uid, params: params})
      PersonDataExpiry.expire @uid
      proxy.get
    end

  end
end
