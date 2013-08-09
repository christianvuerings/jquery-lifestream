# Cacheable merged feed of all of a user's Canvas Courses, Sections, and Groups,
# incorporating enrollment data from campus systems.
#
# Current Dashboard UX divides all Canvas Course and Group memberships between two
# widgets:
#
#   "My Classes" : Canvas Courses, along with Canvas Groups whose context is a
#       Canvas Course where the user is a member. Course descriptions include links back to
#       any connected campus sections in which the current user is officially enrolled
#       or instructing.
#
#   "My Groups" : Other Canvas Groups.
#
# Since "My Groups" depends on the contents of "My Classes", both should draw from
# a single data object.
#
# Because this data structure is used by multiple top-level feeds, it's essential
# that it be cached efficiently.

class CanvasUserSites < MyMergedModel

  def initialize(uid, options=nil)
    super(uid, options)
    @url_root = Settings.canvas_proxy.url_root
  end

  def get_feed_internal
    merged_sites = {
        classes: [],
        groups: []
    }

    # Note that the campus data feed is shared by both the Canvas and bSpace merges.
    campus_user_courses = CampusUserCoursesProxy.new(user_id: @uid).get_campus_courses

    response = CanvasUserCoursesProxy.new(user_id: @uid).courses
    return merged_sites unless (response && response.status == 200)
    course_sites = JSON.parse(response.body)
    course_sites.each do |site|
      merge_course_site(site, merged_sites, campus_user_courses)
    end

    # Ordering is important here! A Canvas Group may refer back to a Canvas Course ID,
    # and so we need to send the list of already-categorized Course sites to the
    # Group site handler.
    response = CanvasGroupsProxy.new(user_id: @uid).groups
    return merged_sites unless (response && response.status == 200)
    group_sites = JSON.parse(response.body)
    group_sites.each do |site|
      merge_group_site(site, merged_sites)
    end

    merged_sites
  end

  private

  def merge_course_site(site, merged_sites, campus_user_courses)
    course_id = site['id']
    role = site['enrollments'][0]['type']
    response = CanvasCourseSectionsProxy.new(course_id: course_id).sections_list
    return merged_sites unless (response && response.status == 200)
    canvas_sections = JSON.parse(response.body)
    linked_course_ids = Set.new
    canvas_sections.each do |canvas_section|
      sis_id = canvas_section['sis_section_id']
      if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(sis_id))
        matched_course_idx = campus_user_courses.index do |coffering|
          #TODO: worth changing this matching if there's a 'GSI' role later on.
          (coffering[:role] == 'Student' || coffering[:role] == 'Instructor') &&
              coffering[:term_yr].to_s == campus_section[:term_yr] &&
              coffering[:term_cd] == campus_section[:term_cd] &&
              coffering[:sections].index{ |csect| csect[:ccn].to_s == campus_section[:ccn] }
        end
        if matched_course_idx
          linked_course_ids.add(campus_user_courses[matched_course_idx][:id])
        end
      else
        Rails.logger.debug("Unparsable sis_section_id #{sis_id} for Canvas course #{course_id}")
      end
    end
    linked_course_ids = linked_course_ids.collect { |co| {id: co}} || []
    merged_sites[:classes] << {
        id: course_id.to_s,
        short_description: site['name'],
        name: site['course_code'],
        site_type: 'course',
        role: role,
        courses: linked_course_ids,
        emitter: CanvasProxy::APP_NAME,
        color_class: "canvas-class",
        site_url: "#{@url_root}/courses/#{course_id}"
    }
  end

  def merge_group_site(site, merged_sites)
    class_sites = merged_sites[:classes]
    if site['context_type'] == 'Course' &&
      (course_site_idx = class_sites.index { |class_site| class_site[:id] == site['course_id'].to_s })
      groups_course = class_sites[course_site_idx]
      merged_sites[:classes] << {
          id: site['id'].to_s,
          name: site['name'],
          site_type: 'group',
          courses: groups_course[:courses],
          source: groups_course[:name],
          emitter: CanvasProxy::APP_NAME,
          color_class: "canvas-class",
          site_url: "#{@url_root}/groups/#{site['id']}"
      }
    else
      merged_sites[:groups] << {
          id: site['id'].to_s,
          name: site['name'],
          site_type: 'group',
          emitter: CanvasProxy::APP_NAME,
          color_class: "canvas-group",
          site_url: "#{@url_root}/groups/#{site['id']}"
      }
    end
  end

end
