class CanvasRosters
  include ActiveAttr::Model, ClassLogger, SafeJsonParser
  extend Calcentral::Cacheable

  PHOTO_UNAVAILABLE_FILENAME = 'photo_unavailable_official_72x96.jpg'

  def self.cache_key(canvas_course_id)
    "global/#{self.name}/#{canvas_course_id}"
  end

  def initialize(uid, options={})
    @uid = uid
    @canvas_course_id = options[:canvas_course_id]
  end

  # Must be protected by a call to "user_authorized?"!
  def get_feed
    if user_authorized?
      self.class.fetch_from_cache @canvas_course_id do
        get_feed_internal
      end
    else
      nil
    end
  end

  def get_feed_internal
    feed = {
        canvas_course: {
            id: @canvas_course_id
        },
        sections: [],
        students: []
    }
    campus_enrollment_map = {}
    # Fill in the Canvas course sections (not to be confused with official campus sections).
    response = CanvasCourseSectionsProxy.new(course_id: @canvas_course_id).sections_list
    return feed unless (response && response.status == 200 && canvas_sections = safe_json(response.body))
    canvas_sections.each do |canvas_section|
      canvas_section_id = canvas_section['id']
      sis_id = canvas_section['sis_section_id']
      feed[:sections] << {
          id: canvas_section_id,
          name: canvas_section['name'],
          sis_id: sis_id
      }
      # Get the official campus section enrollments (if any) which are associated with these Canvas course sections.
      if (campus_section = CanvasProxy.sis_section_id_to_ccn_and_term(sis_id))
        section_enrollments = CampusData.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
        section_enrollments.each do |enr|
          if (existing_entry = campus_enrollment_map[enr['ldap_uid']])
            # We include waitlisted students in the roster. However, we do not show the official photo if the student
            # is waitlisted in ALL sections.
            if existing_entry[:enroll_status] == 'W' &&
                enr['enroll_status'] == 'E'
              existing_entry[:enroll_status] = 'E'
            end
          else
            campus_enrollment_map[enr['ldap_uid']] = {
                student_id: enr['student_id'],
                first_name: enr['first_name'],
                last_name: enr['last_name'],
                enroll_status: enr['enroll_status']
            }
          end
        end
      end
    end
    # We only show students with an official enrollment.
    return feed if campus_enrollment_map.empty?
    # Get the full list of students in the Canvas course for filtering and merging.
    canvas_students = CanvasCourseStudentsProxy.new(course_id: @canvas_course_id).full_students_list
    # Filter and merge the two flavors of enrollment.
    canvas_students.each do |canvas_student|
      login_id = canvas_student['login_id']
      if (campus_student = campus_enrollment_map[login_id])
        campus_student[:id] = canvas_student['id']
        if (canvas_enrollments = canvas_student['enrollments']) && !canvas_enrollments.blank?
          campus_student[:sections] = canvas_enrollments.collect {|enr| {id: enr['course_section_id']} }
          campus_student[:profile_url] = canvas_enrollments[0]['html_url']
        end
        campus_student[:login_id] = login_id
        if campus_student[:enroll_status] == 'E'
          campus_student[:photo] = "/canvas/#{@canvas_course_id}/photo/#{canvas_student['id']}"
        end
        feed[:students] << campus_student
      end
    end
    feed
  end

  # TODO Pre-fetch and cache the student images at a key incorporating the current user's ID.
  # E.g., "user/#{instructor_uid}/CanvasRosters/#{canvas_course_id}/photo/#{student_id}".
  def photo_data_or_file(student_canvas_id)
    roster = get_feed
    return nil if roster.nil?
    if (match = roster[:students].index{|stu| stu[:id] == student_canvas_id})
      student = roster[:students][match]
      if student[:enroll_status] == 'E'
        if (photo_row = CampusData.get_photo(student[:login_id]))
          return {
              size: photo_row['bytes'],
              data: photo_row['photo']
          }
        end
      end
    end
    {
        filename: File.join(Rails.root, 'app/assets/images', PHOTO_UNAVAILABLE_FILENAME)
    }
  end

  def user_authorized?
    # TODO Canvas admins have permission to see the embedded tool, but this check will fail unless they are explicitly a teacher in the course site.
    # Note that bSpace admins are currently permitted to see official photos.
    # To support admins, we either need to trust the LTI param "roles" (will be "urn:lti:instrole:ims/lis/Administrator"),
    # or we need to retrieve all account admins ("/api/v1/accounts/#{UC_ACCOUNT}/admins") and search the list.
    # As a workaround, the admin can temporarily add themselves to the course site as an teacher.
    teachers_list = CanvasCourseTeachersProxy.new(course_id: @canvas_course_id).full_teachers_list
    match = teachers_list.index {|teacher| teacher['login_id'] == @uid}
    if match.nil?
      logger.warn("Unauthorized request from user = #{@uid} for Canvas course #{@canvas_course_id}")
    end
    !match.nil?
  end

end
