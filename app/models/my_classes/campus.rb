class MyClasses::Campus
  include MyClasses::ClassesModule

  def fetch
    # Only include classes for current terms.
    classes = []
    all_courses = CampusOracle::UserCourses.new(user_id: @uid).get_all_campus_courses
    semester_key = "#{current_term.year}-#{current_term.code}"
    if all_courses[semester_key]
      # Ask My Academics for the URL to this class info page in My Academics.
      my_academics = MyAcademics::Semesters.new(@uid)
      all_courses[semester_key].each do |course|
        course[:site_url] = my_academics.class_to_url(course)
        append_class_info(course, classes)
      end
    end
    classes
  end

  def append_class_info(campus_course, class_list)
    if campus_course[:role] != 'Student'
      class_list << campus_course
      return
    end
    # If a student is enrolled or waitlisted in multiple primary sections with the
    # same department and catalog ID, show them as separate "classes" on the dashboard.
    # In very rare cases (notably a student who is waitlisted for multiple primary
    # sections of a large course offering with secondary sections), the sections list
    # of the split class will be somewhat arbitrary. This has no visible effect in
    # the current UX, however.
    split_primaries = multiple_primaries?(campus_course)
    working_course = nil
    campus_course[:sections].each do |section|
      if section[:is_primary_section]
        working_course = campus_course.deep_dup
        if split_primaries
          working_course[:id] = "#{campus_course[:id]}-#{section[:section_number]}"
          working_course[:courseCodeSection] = "#{section[:instruction_format]} #{section[:section_number]}"
        end
        if section[:waitlistPosition] && section[:waitlistPosition] > 0
          working_course[:enroll_limit] = section[:enroll_limit]
          working_course[:waitlistPosition] = section[:waitlistPosition]
        end
        working_course[:sections] = [section]
        class_list << working_course
      else
        working_course[:sections] << section
      end
    end
  end

  def multiple_primaries?(campus_course)
    (campus_course[:sections].select {|section| section[:is_primary_section]}).size > 1
  end
end
