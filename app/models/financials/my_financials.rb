# TODO collapse this class into Financials::Proxy (maybe)
module Financials
  class MyFinancials < UserSpecificModel

    def get_feed_internal
      feed = {}
      if Settings.features.financials
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
      end
      feed
    end

  end
end
