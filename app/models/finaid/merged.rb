module Finaid
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    attr_accessor :proxies

    def initialize(uid, options={})
      super(uid, options)
      @proxies = [
        Finaid::MyFinAid,
        Finaid::MyAwards,
        Finaid::MyBudget
      ]
    end

    def get_feed_internal
      feed = {}
      begin
        self.proxies.each { |proxy_class|
          proxy = proxy_class.new @uid
          proxy.append_feed!(feed)
        }
      rescue => e
        self.class.handle_exception(e, self.class.cache_key(@uid), {
          id: @uid,
          user_message_on_exception: "Remote server unreachable",
          return_nil_on_generic_error: true
        })
      end

      feed
    end

  end
end
