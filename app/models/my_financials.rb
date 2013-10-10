class MyFinancials < MyMergedModel

  def get_feed_internal
    feed = {}
    if Settings.features.financials
      proxy = FinancialsProxy.new({user_id: @uid})
      proxy_response = proxy.get
      if proxy_response && body = proxy_response[:body]
        if student = body["student"]
          feed.merge!(student)
          feed.merge!({"current_term" => Settings.sakai_proxy.current_terms.first})
        end
      end
    end
    feed
  end

end
