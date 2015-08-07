module CampusSolutions
  class MyTitle4 < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::Title4.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
