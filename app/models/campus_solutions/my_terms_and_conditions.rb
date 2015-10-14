module CampusSolutions
  class MyTermsAndConditions < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::TermsAndConditions.new({user_id: @uid, params: params})
      FinancialAidExpiry.expire @uid
      proxy.get
    end

  end
end
