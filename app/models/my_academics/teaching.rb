class MyAcademics::Teaching

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = CampusUserCoursesProxy.new({user_id: @uid})
    feed = proxy.get_all_campus_courses

    teaching_hash = {}

    # The campus courses feed is organized by semesters, with course offerings under them.
    # This view instead organizes by course definitions, with semester-specific course offerings under them.
    feed.values.each do |course_offerings|
      course_offerings.each do |course|
        next unless course[:role] == 'Instructor'
        course_slug = course_to_slug(course[:dept], course[:catid])
        teaching_hash[course_slug] ||= {
            course_number: course[:course_code],
            slug: course_slug,
            title: course[:name],
            semesters: []
        }
        teaching_hash[course_slug][:semesters] << {
            name: TermCodes.to_english(course[:term_yr], course[:term_cd]),
            slug: TermCodes.to_slug(course[:term_yr], course[:term_cd]),
            # TODO Settle role logic ("Instructor" vs. "GSI"), especially for non-grad-students who taught secondary sections.
            role: course[:role],
            # TODO Inject nested sections (if instructor in primary) or nesting section (if GSI in secondary).
            sections: course[:sections]
        }
      end
    end

    data[:teaching] = teaching_hash.values if !teaching_hash.empty?
  end

end
