module CampusSolutions
  class MyAddress < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::Address.new({user_id: @uid, params: params})
      PersonDataExpiry.expire @uid
      proxy.get
    end

  end
end
