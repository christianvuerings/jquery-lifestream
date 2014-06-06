module Rosters
  class Campus < Common
    include ActiveAttr::Model, ClassLogger, SafeJsonParser
    extend Cache::Cacheable

    def get_feed_internal
      feed = {
        campus_course: {
          id: "#{@campus_course_id}"
        },
        sections: [],
        students: []
      }
      campus_enrollment_map = {}

      all_courses = CampusOracle::UserCourses.new({user_id: @uid}).get_all_campus_courses
      selected_course = {}

      all_courses.keys.each do |term|
        semester_courses = all_courses[term]
        match = semester_courses.index do |semester_course|
          (semester_course[:id] == @campus_course_id) &&
            (semester_course[:role] == 'Instructor')
        end
        if !match.nil?
          selected_course = semester_courses[match]
        end
      end

      term_yr = selected_course[:term_yr]
      term_cd = selected_course[:term_cd]
      dept_name = selected_course[:dept]
      catid = selected_course[:catid]

      selected_course[:sections].each do |section|
        feed[:sections] << {
          id: section[:ccn],
          name: "#{dept_name} #{catid} #{section[:section_label]}"
        }

        section_enrollments = CampusOracle::Queries.get_enrolled_students(section[:ccn], term_yr, term_cd)
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
              enroll_status: enr['enroll_status'],
              section_ccns: [section[:ccn]]
            }
          end
        end
      end
      return feed if campus_enrollment_map.empty?
      campus_enrollment_map.keys.each do |id|
        campus_student = campus_enrollment_map[id]
        campus_student[:id] = id
        campus_student[:login_id] = id
        campus_student[:profile_url] = 'https://calnet.berkeley.edu/directory/details.pl?uid=' + id
        campus_student[:sections] = []
        campus_student[:section_ccns].each do |section_ccn|
          campus_student[:sections].push({id: section_ccn})
        end
        if campus_student[:enroll_status] == 'E'
          campus_student[:photo] = "/campus/#{@campus_course_id}/photo/#{id}"
        end
        feed[:students] << campus_student
      end
      feed
    end

    def user_authorized?
      all_courses = CampusOracle::UserCourses.new({user_id: @uid}).get_all_campus_courses
      flag = false
      all_courses.keys.each do |term|
        semester_courses = all_courses[term]
        match = semester_courses.index do |semester_course|
          (semester_course[:id] == @campus_course_id) &&
            (semester_course[:role] == 'Instructor')
        end
        if !match.nil?
          flag = true
        end
      end
      if !flag
        logger.warn("Unauthorized request from user = #{@uid} for Campus course #{@campus_course_id}")
      end
      flag
    end

  end
end
