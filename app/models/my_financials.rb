class MyFinancials < MyMergedModel

  def get_feed_internal
    proxy = FinancialsProxy.new({:user_id => @uid})
    body = proxy.get.try(:[], :body)
    body.try(:[], "student") || {}
  end

end
