module CampusSolutions
  class MyPhone < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::Phone.new({user_id: @uid, params: params})
      PersonDataExpiry.expire @uid
      proxy.get
    end

  end
end
