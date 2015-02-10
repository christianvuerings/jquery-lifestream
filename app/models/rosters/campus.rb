module Rosters
  class Campus < Common

    def get_feed_internal
      feed = {
        campus_course: {
          id: "#{@campus_course_id}"
        },
        sections: [],
        students: []
      }
      all_courses = CampusOracle::UserCourses::All.new({user_id: @uid}).get_all_campus_courses

      selected_term, selected_course = nil
      all_courses.each do |term, courses|
        if (course = courses.find {|c| (c[:id] == @campus_course_id) && (c[:role] == 'Instructor') })
          selected_term = term
          selected_course = course
          break
        end
      end

      return feed if selected_course.nil?
      feed[:campus_course].merge!(name: selected_course[:name])

      crosslisted_courses = []
      if (crosslisted_section = selected_course[:sections].find { |section| section[:cross_listing_hash].present? })
        crosslisting_hash = crosslisted_section[:cross_listing_hash]
        crosslisted_courses = all_courses[selected_term].select do |course|
          course[:sections].find { |section| section[:cross_listing_hash] == crosslisting_hash }
        end
      else
        crosslisted_courses << selected_course
      end

      campus_enrollment_map = {}
      crosslisted_courses.each do |course|
        course[:sections].each do |section|
          feed[:sections] << {
            ccn: section[:ccn],
            name: "#{course[:dept]} #{course[:catid]} #{section[:section_label]}"
          }

          section_enrollments = CampusOracle::Queries.get_enrolled_students(section[:ccn], course[:term_yr], course[:term_cd])
          section_enrollments.each do |enr|
            if (existing_entry = campus_enrollment_map[enr['ldap_uid']])
              # We include waitlisted students in the roster. However, we do not show the official photo if the student
              # is waitlisted in ALL sections.
              if existing_entry[:enroll_status] == 'W' &&
                enr['enroll_status'] == 'E'
                existing_entry[:enroll_status] = 'E'
              end
              campus_enrollment_map[enr['ldap_uid']][:section_ccns] |= [section[:ccn]]
            else
              campus_enrollment_map[enr['ldap_uid']] = {
                student_id: enr['student_id'],
                first_name: enr['first_name'],
                last_name: enr['last_name'],
                email: enr['student_email_address'],
                enroll_status: enr['enroll_status'],
                section_ccns: [section[:ccn]],
                photo_bytes: enr['photo_bytes']
              }
            end
          end
        end
      end

      # Create sections hash indexed by CCN
      sections_index = index_by_attribute(feed[:sections], :ccn)

      return feed if campus_enrollment_map.empty?
      campus_enrollment_map.keys.each do |id|
        campus_student = campus_enrollment_map[id]
        campus_student[:id] = id
        campus_student[:login_id] = id
        campus_student[:profile_url] = 'https://calnet.berkeley.edu/directory/details.pl?uid=' + id
        campus_student[:sections] = []
        campus_student[:section_ccns].each do |section_ccn|
          campus_student[:sections].push(sections_index[section_ccn])
        end
        if campus_student[:enroll_status] == 'E' && campus_student[:photo_bytes]
          campus_student[:photo] = "/campus/#{@campus_course_id}/photo/#{id}"
        end
        feed[:students] << campus_student
      end
      feed
    end

  end
end
