class MyFinancials < MyMergedModel

  def get_feed_internal
    logger.info "uid = #{@uid}"
    proxy = FinancialsProxy.new({:user_id => @uid})
    response = proxy.get
    body = response.try(:[], :body)
    body.try(:[], "student") || {}
  end

end
