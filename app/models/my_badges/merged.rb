module MyBadges
  class Merged < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonCacher
    include Cache::FilteredViewAsFeed

    GOOGLE_SOURCES = {
      'bcal' => GoogleCalendar,
      'bdrive' => GoogleDrive,
      'bmail' => GoogleMail
    }

    def initialize(uid, options={})
      super(uid, options)
      @now_time = Time.zone.now
    end

    def get_feed_internal
      feed = {
        badges: get_google_badges,
        studentInfo: StudentInfo.new(@uid).get
      }
      feed[:alert] = EtsBlog::Alerts.new.get_latest if Settings.features.app_alerts
      logger.debug "#{self.class.name} get_feed is #{feed.inspect}"
      feed
    end

    def filter_for_view_as(feed)
      filtered_badges = {}
      GOOGLE_SOURCES.each_key do |key|
        filtered_badges[key] = {
          count: 0,
          items: []
        }
      end
      feed[:badges] = filtered_badges
      feed
    end

    def get_google_badges
      badges = {}
      if GoogleApps::Proxy.access_granted?(@uid)
        GOOGLE_SOURCES.each do |key, provider|
          badges[key] = provider.new(@uid).fetch_counts
        end
      end
      badges
    end

  end
end
