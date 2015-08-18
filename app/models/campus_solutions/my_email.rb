module CampusSolutions
  class MyEmail < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::Email.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
