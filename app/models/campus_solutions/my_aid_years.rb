module CampusSolutions
  class MyAidYears < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include CampusSolutions::FinaidFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      CampusSolutions::AidYears.new({user_id: @uid}).get
    end

  end
end
