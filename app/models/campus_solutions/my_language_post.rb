module CampusSolutions
  class MyLanguagePost < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::LanguagePost.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
