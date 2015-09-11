module CampusSolutions
  class MyChecklist < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    def get_feed_internal
      CampusSolutions::Checklist.new({user_id: @uid}).get
    end

  end
end
