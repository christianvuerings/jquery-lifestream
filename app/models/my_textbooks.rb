class MyTextbooks < MyMergedModel

  def initialize(uid, options={})
    @uid = uid
    @ccns = options[:ccns]
    @ccn = @ccns[0]
    @slug = options[:slug]
  end

  def get_feed(*opts)
    self.class.fetch_from_cache @ccn do
      init
      feed = get_feed_internal(*opts)
      notify_if_feed_changed(feed, @ccn)
      feed
    end
  end

  def get_feed_as_json(*opts)
    self.class.fetch_from_cache "json-#{@ccn}" do
      feed = get_feed(*opts)
      feed.to_json
    end
  end

  def get_feed_internal
    feed = {}
    if Settings.features.textbooks
      proxy = TextbooksProxy.new({user_id: @uid, ccns: @ccns, slug: @slug})
      proxy_response = proxy.get
      feed = proxy_response[:body]
    end
    feed
  end

end
