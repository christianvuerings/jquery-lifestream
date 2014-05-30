module Financials
  # This model class caches a JSON translation of CFV data fetched by Financials::Proxy.
  # Inheriting from UserSpecificModel means it participates in the live-updates cache
  # invalidation and warmup cycle. At the model layer the cache entries persist forever
  # until a live-updates cycle hits them (see LiveUpdatesWarmer and IsUpdatedController).
  # At the proxy layer cache entries have shorter expiration times, tuned to the external
  # data's update frequency.
  class MyFinancials < UserSpecificModel

    include Cache::LiveUpdatesEnabled

    def get_feed_internal
      feed = {}
      proxy = Financials::Proxy.new({user_id: @uid})
      proxy_response = proxy.get
      if proxy_response && body = proxy_response[:body]
        if body.is_a?(Hash) && student = body["student"]
          feed.merge!(student)
          feed.merge!({"currentTerm" => Berkeley::Terms.fetch.current.to_english})
          feed.merge!({"apiVersion" => proxy_response[:apiVersion]})
        else
          feed.merge!(proxy_response)
        end
      end
      feed
    end

  end
end
