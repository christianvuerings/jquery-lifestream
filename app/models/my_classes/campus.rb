module MyClasses
  class Campus
    include ClassesModule

    def fetch
      terms = {current: classes_for_term(current_term)}
      terms.merge!({gradingInProgress: classes_for_term(grading_in_progress_term)}) if grading_in_progress_term
      terms
    end

    def classes_for_term(term)
      classes = []
      all_courses = CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
      semester_key = "#{term.year}-#{term.code}"
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
      # In a case such as a student who is waitlisted for multiple primary
      # sections of a large course offering with secondary sections, we'll try our best
      # to associate primaries and secondaries based on the course_option value, but
      # success is not guaranteed.
      primary_sections, secondary_sections = campus_course[:sections].partition {|section| section[:is_primary_section]}

      primary_sections.each do |section|
        working_course = campus_course.deep_dup
        if primary_sections.count > 1
          working_course[:listings].each do |listing|
            listing[:id] = "#{listing[:id]}-#{section[:section_number]}"
          end
          working_course[:listings].first[:courseCodeSection] = "#{section[:instruction_format]} #{section[:section_number]}"
          working_course[:site_url] << "/#{section[:instruction_format].downcase}-#{section[:section_number]}"
        end
        if section[:waitlistPosition] && section[:waitlistPosition] > 0
          working_course[:enroll_limit] = section[:enroll_limit]
          working_course[:waitlistPosition] = section[:waitlistPosition]
        end
        working_course[:sections] = [section]
        working_course.delete :course_option
        class_list << working_course
      end

      secondary_sections.each do |sec|
        primary = primary_sections.find { |prim| Berkeley::CourseOptions.nested?(campus_course[:course_option], prim[:section_number], sec[:section_number], sec[:instruction_format]) }
        # Fallback if we can't find anything nested
        primary ||= primary_sections.first
        primary_in_class_list = class_list.find { |course| course[:sections].first[:ccn] == primary[:ccn]}
        primary_in_class_list[:sections] << sec
      end
    end

  end
end
