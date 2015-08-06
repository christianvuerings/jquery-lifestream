module CampusSolutions
  class MyTermsAndConditions < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::TermsAndConditions.new({user_id: @uid, params: params})
      proxy.get
    end

  end
end
