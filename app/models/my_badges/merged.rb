module MyBadges
  class Merged < UserSpecificModel
    include Cache::LiveUpdatesEnabled

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

    def get_google_badges
      badges = {}
      google_enabled = !is_acting_as_nonfake_user? && GoogleApps::Proxy.access_granted?(@uid)
      {
        'bcal' => GoogleCalendar,
        'bdrive' => GoogleDrive,
        'bmail' => GoogleMail
      }.each do |key, provider|
        if google_enabled
          badges[key] = provider.new(@uid).fetch_counts
        else
          badges[key] = {
            count: 0,
            items: []
          }
        end
      end
      badges
    end

  end
end
