class MyAcademics::Teaching

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = CampusUserCoursesProxy.new({user_id: @uid})
    feed = proxy.get_all_campus_courses

    teaching_semesters = []

    # The campus courses feed is organized by semesters, with course offerings under them.
    feed.keys.each do |term_key|
      (term_yr, term_cd) = term_key.split("-")
      teaching_semester = semester_info(term_yr, term_cd)
      feed[term_key].each do |course|
        next unless course[:role] == 'Instructor'
        teaching_semester[:classes] << class_info(course).merge({
            # TODO Settle role logic ("Instructor" vs. "GSI"), especially for non-grad-students who taught secondary sections.
            role: course[:role]
            # TODO Inject nested sections (if instructor in primary) or nesting section (if GSI in secondary).
            # TODO Add class sites with section linkages.
        })
      end
      teaching_semesters << teaching_semester unless teaching_semester[:classes].empty?
    end

    data[:teaching_semesters] = teaching_semesters unless teaching_semesters.empty?
  end

end
