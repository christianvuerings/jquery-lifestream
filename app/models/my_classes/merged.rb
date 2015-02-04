module MyClasses
  class Merged < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    def get_feed_internal
      sites = []
      campus = Campus.new(@uid)
      campus_courses = campus.fetch
      sites.concat(campus_courses)
      Canvas.new(@uid).merge_sites(campus_courses, sites)
      SakaiClasses.new(@uid).merge_sites(campus_courses, sites)
      {
        classes: sites,
        current_term: campus.current_term.to_english
      }
    end

  end
end
