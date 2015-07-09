module MyClasses
  class Merged < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher

    def get_feed_internal
      campus = Campus.new(@uid)
      campus_courses = campus.fetch
      site_emitters = [
        Canvas.new(@uid),
        SakaiClasses.new(@uid)
      ]
      feed = {
        classes: merge_sites(campus_courses[:current], campus.current_term, site_emitters),
        current_term: campus.current_term.to_english
      }
      if campus_courses[:gradingInProgress]
        feed[:gradingInProgressClasses] = merge_sites(campus_courses[:gradingInProgress], campus.grading_in_progress_term, site_emitters)
      end
      feed
    end

    def merge_sites(courses, term, emitters)
      sites = courses.dup
      emitters.each { |emitter| emitter.merge_sites(courses, term, sites) }
      sites
    end
  end
end
