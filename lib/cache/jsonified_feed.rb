# Return and cache only the JSONified version of the feed. This mix-in is best suited for
# large complex data structures which do not need frequent parsing.
module Cache
  module JsonifiedFeed

    def self.included base
      base.extend ClassMethods
    end

    def get_feed_as_json(force_cache_write=false)
      get_feed(force_cache_write)
    end

    module ClassMethods
      def process_response_before_caching(response, opts)
        # JSONification needs to be done last.
        response = super(response, opts)
        response.to_json
      end
    end

  end
end
