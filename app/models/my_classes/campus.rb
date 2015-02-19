module MyClasses
  class Campus
    include ClassesModule

    def fetch
      # Only include classes for current terms.
      classes = []
      all_courses = CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
      semester_key = "#{current_term.year}-#{current_term.code}"
      if all_courses[semester_key]
        # Ask My Academics for the URL to this class info page in My Academics, and to merge
        # any crosslisted courses for non-students.
        my_academics = MyAcademics::Semesters.new(@uid)
        listing_specific_properties = [:catid, :course_catalog, :course_code, :dept, :dept_desc, :id]
        all_courses[semester_key].each do |course|
          course_info = course.except *listing_specific_properties
          course_info[:listings] = [ course.slice(*listing_specific_properties) ]
          course_info[:site_url] = my_academics.class_to_url course
          if course[:role] == 'Student'
            append_class_info(classes, course_info)
          else
            my_academics.append_with_merged_crosslistings(classes, course_info)
          end
        end
      end
      classes
    end

    def append_class_info(class_list, campus_course)
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
            working_course[:listings].each do |listing|
              listing[:id] = "#{listing[:id]}-#{section[:section_number]}"
            end
            working_course[:listings].first[:courseCodeSection] = "#{section[:instruction_format]} #{section[:section_number]}"
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
end
