module CampusSolutions
  class MyTitle4 < UserSpecificModel

    def update(params = {})
      proxy = CampusSolutions::Title4.new({user_id: @uid, params: params})
      FinancialAidExpiry.expire @uid
      proxy.get
    end

  end
end
