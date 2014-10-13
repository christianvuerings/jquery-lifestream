module Advising
  class MyAdvising < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled

    def default_message_on_exception
      'Failed to connect with your department\'s advising system.'
    end

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
