module MyAcademics
  class Teaching
    include AcademicsModule

    def merge(data)
      proxy = CampusOracle::UserCourses.new({user_id: @uid})
      feed = proxy.get_all_campus_courses

      teaching_semesters = []

      # The campus courses feed is organized by semesters, with course offerings under them.
      feed.keys.each do |term_key|
        (term_yr, term_cd) = term_key.split("-")
        teaching_semester = semester_info(term_yr, term_cd).merge({
          timeBucket: AcademicsModule.time_bucket(term_yr, term_cd),
        })
        feed[term_key].each do |course|
          next unless course[:role] == 'Instructor'
          teaching_semester[:classes] << class_info(course).merge({
              role: course[:role]
          })
        end
        teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
      end

      if teaching_semesters.present?
        [
          MyAcademics::TeachingCanvas,
          MyAcademics::TeachingSakai,
        ].each do |site_provider|
          site_provider.new(@uid).merge_sites(teaching_semesters)
        end
        data[:teachingSemesters] = teaching_semesters
      end
    end
  end
end
