module CampusSolutions
  module PersonDataUpdatingModel
    def passthrough(model_name, params)
      proxy = model_name.new({user_id: @uid, params: params})
      PersonDataExpiry.expire @uid
      proxy.get
    end
  end
end
