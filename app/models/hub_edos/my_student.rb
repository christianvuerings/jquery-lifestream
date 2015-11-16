module HubEdos
  class MyStudent < UserSpecificModel

    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include CampusSolutions::ProfileFeatureFlagged

    def get_feed_internal
      merged = {
        feed: {
          student: {}
        },
        statusCode: 200
      }
      return merged unless is_cs_profile_feature_enabled

      [HubEdos::Contacts, HubEdos::Demographics, HubEdos::Affiliations].each do |proxy|
        feed = proxy.new({user_id: @uid}).get
        if feed[:statusCode] > 400
          merged[:statusCode] = 500
          merged[:errored] = true
          logger.error("Got errors in merged student feed on #{proxy} for uid #{@uid}")
        else
          merged[:feed][:student].merge!(feed[:feed]['student'])
        end
      end
      merged
    end

  end
end
