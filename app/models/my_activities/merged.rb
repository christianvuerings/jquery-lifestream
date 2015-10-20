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
        MyActivities::CanvasActivities      ]
      @proxies = [
        MyActivities::NotificationActivities,
        MyActivities::RegBlocks,
        MyActivities::Webcasts,
        MyActivities::CampusSolutionsMessages
      ]
    end

    def self.cutoff_date
      @cutoff_date ||= (Settings.terms.fake_now || Time.zone.today.in_time_zone).to_datetime.advance(days: -10).to_time.to_i
    end

    # Note that MyActivities feed processing has a direct dependency on MyClasses and MyGroups.
    def get_feed_internal
      activities = []
      dashboard_sites = MyActivities::DashboardSites.fetch(@uid, @options)
      campus_solutions_dashboard_url = CampusSolutions::DashboardUrl.new.get
      self.site_proxies.each { |proxy| proxy.append!(@uid, dashboard_sites, activities) }
      self.proxies.each { |proxy| proxy.append!(@uid, activities) }
      {
        activities: activities,
        archiveUrl: campus_solutions_dashboard_url[:feed][:url]
      }
    end

  end
end
