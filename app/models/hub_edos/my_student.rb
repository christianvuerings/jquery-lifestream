module HubEdos
  class MyStudent < UserSpecificModel

    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    def get_feed_internal
      HubEdos::Student.new({user_id: @uid}).get
    end

  end
end
