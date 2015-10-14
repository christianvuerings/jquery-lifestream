module CampusSolutions
  class MyAidYears < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    def get_feed_internal
      CampusSolutions::AidYears.new({user_id: @uid}).get
    end

  end
end
