class MyFinancials < MyMergedModel

  def get_feed_internal
    if Settings.features.financials
      proxy = FinancialsProxy.new({user_id: @uid})
      body = proxy.get.try(:[], :body)
      body.try(:[], "student") || {}
    else
      {}
    end
  end

end
