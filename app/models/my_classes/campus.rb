class MyClasses::Campus
  include MyClasses::ClassesModule

  def fetch
    # Only include classes for current terms.
    classes = []
    all_courses = CampusUserCoursesProxy.new(user_id: @uid).get_all_campus_courses
    @current_terms.each do |term|
      semester_key = "#{term.term_yr}-#{term.term_cd}"
      if all_courses[semester_key]
        all_courses[semester_key].each do |course|
          course[:site_url] = MyAcademics::AcademicsModule.class_to_url(
            course[:term_cd],
            course[:term_yr],
            course[:dept],
            course[:catid],
            course[:role]
          )
          classes << course
        end
      end
    end
    classes
  end
end
