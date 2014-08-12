# TODO collapse this class into Advising::Proxy (maybe)
module Advising
  class MyAdvising < UserSpecificModel

    include Cache::LiveUpdatesEnabled

    def get_feed_internal
      feed = {}
      if Settings.features.advising
        proxy = Advising::Proxy.new({user_id: @uid})
        proxy_response = proxy.get
        if proxy_response.is_a?(Hash)
          feed.merge!(proxy_response)
        end
      end
      feed
    end

  end
end
