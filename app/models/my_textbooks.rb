class MyTextbooks < SingleSourceModel

  def initialize(options={})
    @ccns = options[:ccns]
    @ccn = @ccns[0]
    @slug = options[:slug]
  end

  def get_feed_as_json(*opts)
    get_feed_internal
  end

  def get_feed_internal
    feed = {}
    if Settings.features.textbooks
      proxy = TextbooksProxy.new({ccns: @ccns, slug: @slug})
      proxy_response = proxy.get_as_json
      feed = proxy_response
    end
    feed
  end

end
