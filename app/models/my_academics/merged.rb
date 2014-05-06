module MyAcademics
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled

    # If MyAcademics ever includes data from data sources OTHER than our Bearfacts materialized views,
    # which are updated only once a day, then remove this in favor of the normal expiration scheme.
    def self.expires_in
      self.bearfacts_derived_expiration
    end

    def get_feed_internal
      feed = {}
      [
        CollegeAndLevel,
        GpaUnits,
        Requirements,
        Regblocks,
        Semesters,
        Teaching,
        Exams,
        Telebears,
      ].each do |provider|
        provider.new(@uid).merge(feed)
      end
      feed
    end
  end
end
