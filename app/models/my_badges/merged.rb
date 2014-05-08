module MyBadges
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled

    def initialize(uid, options={})
      super(uid, options)
      @now_time = Time.zone.now
    end

    def init
      @enabled_sources ||= {
        "bcal" => {access_granted: GoogleApps::Proxy.access_granted?(@uid),
                     source: MyBadges::GoogleCalendar.new(@uid),
                     pseudo_enabled: GoogleApps::Proxy.allow_pseudo_user?},
        "bdrive" => {access_granted: GoogleApps::Proxy.access_granted?(@uid),
                     source: MyBadges::GoogleDrive.new(@uid),
                     pseudo_enabled: GoogleApps::Proxy.allow_pseudo_user?},
        "bmail" => {access_granted: GoogleApps::Proxy.access_granted?(@uid),
                     source: MyBadges::GoogleMail.new(@uid),
                     pseudo_enabled: GoogleApps::Proxy.allow_pseudo_user?}
      }
      @service_list ||= @enabled_sources.keys.to_a
      @enabled_sources.select!{|k,v| v[:access_granted] == true}
      @student_info_instance = MyBadges::StudentInfo.new(@uid)
      @alert_instance = EtsBlog::Alerts.new if Settings.features.app_alerts
    end

    def get_feed_internal
      badges = {}
      @enabled_sources.each do |key, value_hash|
        if (is_acting_as_nonfake_user?) && !value_hash[:pseudo_enabled]
          next
        end
        badges[key] = value_hash[:source].fetch_counts
      end

      #Appending empty counts for non-enabled services
      @service_list.each do |service|
        badges[service] ||= {
          count: 0,
          items: []
        }
      end
      logger.debug "#{self.class.name} get_feed is #{badges.inspect}"

      result = {}
      result.merge!(:alert => @alert_instance.get_latest) unless @alert_instance.nil?
      result.merge!(:badges => badges)
      result.merge!(:studentInfo => @student_info_instance.get)
    end

  end
end
