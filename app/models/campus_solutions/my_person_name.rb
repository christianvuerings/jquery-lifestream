module CampusSolutions
  class MyPersonName < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::PersonName.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
