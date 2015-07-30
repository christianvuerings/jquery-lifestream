module MyClasses
  class SakaiClasses
    include MyClasses::ClassesModule

    def merge_sites(campus_courses, term, sites)
      return unless Sakai::Proxy.access_granted?(@uid)
      sakai_sites = Sakai::SakaiMergedUserSites.new(user_id: @uid).get_feed
      sakai_sites[:courses].each do |course_site|
        if (entry = course_site_entry(campus_courses, course_site, term))
          sites << entry
        end
      end
    end

  end
end
