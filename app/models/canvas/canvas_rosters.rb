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
      # Look up Canvas course sections associated with official campus sections.
      official_sections = Canvas::CourseSections.new(course_id: @canvas_course_id).official_section_identifiers
      return feed unless official_sections
      official_sections.each do |official_section|
        canvas_section_id = official_section['id'].to_s
        sis_id = official_section['sis_section_id']
        feed[:sections] << {
          id: canvas_section_id,
          name: official_section['name'],
          sis_id: sis_id
        }

        section_enrollments = CampusOracle::Queries.get_enrolled_students(official_section[:ccn], official_section[:term_yr], official_section[:term_cd])
        section_enrollments.each do |enr|
          if (existing_entry = campus_enrollment_map[enr['ldap_uid']])
            existing_entry[:sections] << {id: canvas_section_id}
            existing_entry[:section_ccns] << canvas_section_id
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
              photo_bytes: enr['photo_bytes'],
              sections: [{id: canvas_section_id}],
              section_ccns: [canvas_section_id]
            }
          end
        end
      end

      campus_enrollment_map.each do |ldap_uid, campus_student|
        campus_student[:id] = ldap_uid
        campus_student[:login_id] = ldap_uid
        if campus_student[:enroll_status] == 'E' && campus_student[:photo_bytes]
          campus_student[:photo] = "/canvas/#{@canvas_course_id}/photo/#{ldap_uid}"
        end
        feed[:students] << campus_student
      end

      feed
    end

    def profile_url_for_ldap_id(ldap_id)
      if (user_profile = Canvas::SisUserProfile.new(user_id: ldap_id).get) && user_profile['id']
        "#{Settings.canvas_proxy.url_root}/courses/#{@canvas_course_id}/users/#{user_profile['id']}"
      end
    end

  end
end
