class MyFinancials < MyMergedModel

  def get_feed_internal
    logger.info "uid = #{@uid}"
    proxy = FinancialsProxy.new({:user_id => @uid})
    proxy.get[:body] || {}
  end

end
