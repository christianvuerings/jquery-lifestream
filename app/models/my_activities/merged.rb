module MyActivities
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    attr_accessor :site_proxies
    attr_accessor :proxies

    def initialize(uid, options={})
      super(uid, options)
      @site_proxies = [
        MyActivities::CanvasActivities,
        MyActivities::SakaiAnnouncements
      ]
      @proxies = [
        MyActivities::NotificationActivities,
        MyActivities::RegBlocks,
      ]
    end

    def self.cutoff_date
      @cutoff_date ||= Time.zone.today.in_time_zone.to_datetime.advance(:days => -10).to_time.to_i
    end

    # Note that MyActivities feed processing has a direct dependency on MyClasses and MyGroups.
    def get_feed_internal
      activities = []
      dashboard_sites = MyActivities::DashboardSites.fetch(@uid, @options)
      self.site_proxies.each { |proxy| proxy.append!(@uid, dashboard_sites, activities) }
      self.proxies.each { |proxy| proxy.append!(@uid, activities) }
      { :activities => activities }
    end

  end
end
