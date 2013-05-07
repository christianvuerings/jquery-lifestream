module MyBadges
  module BadgesModule
    def self.included(klass)
      klass.extend Calcentral::Cacheable
    end

    def fetch_counts
      0
    end

    def expire_cache(uid)
      self.class.expire uid
    end
  end
end