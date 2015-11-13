module CampusSolutions
  module PersonDataUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      result = proxy.get
      PersonDataExpiry.expire_on_profile_change @uid
      result
    end
  end
end
