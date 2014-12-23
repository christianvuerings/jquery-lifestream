module Canvas
  class CanvasRosters < Rosters::Common
    include SafeJsonParser

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
      response = Canvas::CourseSections.new(course_id: @canvas_course_id).sections_list
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
        if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(sis_id))
          section_enrollments = CampusOracle::Queries.get_enrolled_students(campus_section[:ccn], campus_section[:term_yr], campus_section[:term_cd])
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
                email: enr['student_email_address'],
                enroll_status: enr['enroll_status'],
                photo_bytes: enr['photo_bytes']
              }
            end
          end
        end
      end
      # We only show students with an official enrollment.
      return feed if campus_enrollment_map.empty?
      # Get the full list of students in the Canvas course for filtering and merging.
      canvas_students = Canvas::CourseStudents.new(course_id: @canvas_course_id).full_students_list
      # Filter and merge the two flavors of enrollment.
      canvas_students.each do |canvas_student|
        login_id = canvas_student['login_id']
        if (campus_student = campus_enrollment_map[login_id])
          campus_student[:id] = canvas_student['id']
          if (canvas_enrollments = canvas_student['enrollments']) && !canvas_enrollments.blank?
            campus_student[:sections] = canvas_enrollments.collect { |enr| {id: enr['course_section_id']} }
            campus_student[:profile_url] = canvas_enrollments[0]['html_url']
          end
          campus_student[:login_id] = login_id
          if campus_student[:enroll_status] == 'E' && campus_student[:photo_bytes]
            campus_student[:photo] = "/canvas/#{@canvas_course_id}/photo/#{canvas_student['id']}"
          end
          feed[:students] << campus_student
        end
      end
      feed
    end

  end
end
