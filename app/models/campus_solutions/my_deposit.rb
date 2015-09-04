module CampusSolutions
  class MyDeposit < UserSpecificModel

    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include Cache::RelatedCacheKeyTracker

    attr_accessor :adm_appl_nbr

    def get_feed_internal
      logger.debug "User #{@uid}; aid adm_appl_nbr #{adm_appl_nbr}"
      CampusSolutions::Deposit.new({user_id: @uid, adm_appl_nbr: adm_appl_nbr}).get
    end

    def instance_key
      "#{@uid}-#{adm_appl_nbr}"
    end

    def get_feed(force_cache_write=false)
      self.class.save_related_cache_key(@uid, self.class.cache_key(instance_key))
      super force_cache_write
    end

  end
end
