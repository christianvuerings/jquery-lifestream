module MyActivities
  class DashboardSites
    def self.fetch(uid, options={})
      dashboard_sites = MyClasses::Merged.new(uid, options).get_feed[:classes]
      dashboard_sites.concat(MyGroups::Merged.new(uid, options).get_feed[:groups])
      dashboard_sites
    end
  end
end
