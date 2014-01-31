class MyClasses::Sakai
  include MyClasses::ClassesModule

  def merge_sites(campus_courses, sites)
    return unless SakaiProxy.access_granted?(@uid)
    sakai_sites = SakaiMergedUserSites.new(user_id: @uid).get_feed
    sakai_sites[:courses].each do |course_site|
      if (entry = course_site_entry(campus_courses, course_site))
        sites << entry
      end
    end
  end

end
