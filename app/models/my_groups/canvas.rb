class MyGroups::Canvas
  include MyGroups::GroupsModule

  def fetch
    sites = []
    return sites unless CanvasProxy.access_granted?(@uid)
    canvas_sites = CanvasMergedUserSites.new(@uid).get_feed
    included_course_sites = []
    canvas_sites[:courses].each do |course_site|
      if (entry = course_site_entry(course_site))
        sites << entry
        included_course_sites << entry[:id]
      end
    end
    canvas_sites[:groups].each do |group_site|
      if (entry = group_site_entry(included_course_sites, group_site))
        sites << entry
      end
    end
    sites
  end

  def course_site_entry(course_site)
    if course_site[:term_yr].blank? && course_site[:term_cd].blank?
      {
        emitter: course_site[:emitter],
        id: course_site[:id],
        name: course_site[:name],
        short_description: course_site[:short_description],
        site_type: 'course',
        site_url: course_site[:site_url]
      }
    else
      nil
    end
  end

  def group_site_entry(included_course_sites, group_site)
    course_link = group_site[:course_id]
    if course_link.blank? || included_course_sites.include?(course_link)
      {
        emitter: group_site[:emitter],
        id: group_site[:id],
        name: group_site[:name],
        site_type: 'group',
        site_url: group_site[:site_url]
      }
    else
      nil
    end
  end
end
