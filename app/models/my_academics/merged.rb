module MyAcademics
  class Merged < UserSpecificModel

    include Cache::LiveUpdatesEnabled

    def get_feed_internal
      feed = {}
      # Provider ordering is significant! In particular, Semesters/Teaching must
      # be merged before course sites.
      [
        CollegeAndLevel,
        GpaUnits,
        Requirements,
        Regblocks,
        Semesters,
        Teaching,
        Exams,
        Telebears,
        CanvasSites,
        SakaiSites
      ].each do |provider|
        provider.new(@uid).merge(feed)
      end
      feed
    end
  end
end
