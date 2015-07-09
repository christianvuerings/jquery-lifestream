module MyActivities
  class DashboardSites
    def self.fetch(uid, options={})
      classes_feed = MyClasses::Merged.new(uid, options).get_feed
      groups_feed = MyGroups::Merged.new(uid, options).get_feed
      classes_feed[:classes] + classes_feed[:gradingInProgressClasses].to_a + groups_feed[:groups]
    end
  end
end
