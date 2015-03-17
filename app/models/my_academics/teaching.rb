module MyAcademics
  class Teaching
    include AcademicsModule

    def merge(data)
      proxy = CampusOracle::UserCourses::All.new({user_id: @uid})
      feed = proxy.get_all_campus_courses

      teaching_semesters = []

      # The campus courses feed is organized by semesters, with course offerings under them.
      feed.keys.each do |term_key|
        teaching_semester = semester_info term_key
        feed[term_key].each do |course|
          next unless course[:role] == 'Instructor'
          course_info = course_info_with_multiple_listings course
          append_with_merged_crosslistings(teaching_semester[:classes], course_info)
        end
        teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
      end

      if teaching_semesters.present?
        data[:teachingSemesters] = teaching_semesters
      end
    end
  end
end
