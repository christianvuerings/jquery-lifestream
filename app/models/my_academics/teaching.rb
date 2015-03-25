module MyAcademics
  class Teaching
    include AcademicsModule

    def merge(data)
      proxy = CampusOracle::UserCourses::All.new({user_id: @uid})
      feed = proxy.get_all_campus_courses
      teaching_semesters = format_teaching_semesters(feed)
      if teaching_semesters.present?
        data[:teachingSemesters] = teaching_semesters
      end
    end

    # Our bCourses Canvas integration occasionally needs to create an Academics Teaching Semesters
    # list based on an explicit set of CCNs.
    def courses_list_from_ccns(term_yr, term_code, ccns)
      proxy = CampusOracle::UserCourses::SelectedSections.new({user_id: @uid})
      feed = proxy.get_selected_sections(term_yr, term_code, ccns)
      format_teaching_semesters(feed, true)
    end

    def format_teaching_semesters(sections_data, ignore_roles = false)
      teaching_semesters = []
      # The campus courses data is organized by semesters, with course offerings under them.
      sections_data.keys.each do |term_key|
        teaching_semester = semester_info term_key
        sections_data[term_key].each do |course|
          next unless ignore_roles || (course[:role] == 'Instructor')
          course_info = course_info_with_multiple_listings course
          append_with_merged_crosslistings(teaching_semester[:classes], course_info)
        end
        teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
      end
      teaching_semesters
    end

  end
end
