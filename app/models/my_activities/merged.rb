module MyActivities
  class Merged < MyMergedModel

    attr_accessor :proxies

    def initialize(uid, options={})
      super(uid, options)

      @proxies = [
        MyActivities::Canvas,
        MyActivities::Notifications,
        MyActivities::SakaiAnnouncements,
        MyActivities::RegBlocks,
      ]
      @proxies << MyActivities::MyFinAid if Settings.features.my_fin_aid
    end

    def self.cutoff_date
      @cutoff_date ||= Time.zone.today.to_time_in_current_zone.to_datetime.advance(:days => -10).to_i
    end

    def get_feed_internal
      activities = []
      self.proxies.each { |proxy| proxy.append!(@uid, activities) }
      { :activities => activities }
    end

  end
end
