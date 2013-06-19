class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = CampusUserCoursesProxy.new({:user_id => @uid})
    feed = proxy.get_campus_courses

    semesters = []
    schedule = []

    feed.each do |course|
      course_number = course[:course_code]
      next unless course_number.strip.length

      units = course[:unit]
      title = course[:name].titleize
      if course[:pnp_flag].present?
        grade_option = course[:pnp_flag].upcase == "Y" ? "P/NP" : "Letter"
      else
        Rails.logger.warn "#{self.class.name} - Course #{course[:ccn]} has a empty 'pnp_flag' field: #{course}"
        grade_option = ''
      end
      ccn = course[:ccn]
      format = course[:instruction_format]
      section = course[:section_num]
      schedules = course[:schedules]
      instructors = course[:instructors]
      schedule << {
        :course_number => course_number,
        :ccn => ccn,
        :title => title,
        :units => units,
        :grade_option => grade_option,
        :section => section,
        :format => format,
        :schedules => schedules,
        :instructors => instructors
      }
    end

    # TODO handle multiple current semesters as defined in Settings.current_terms_codes
    semester_name = TermCodes.to_english Settings.sakai_proxy.current_terms_codes[0].term_yr, Settings.sakai_proxy.current_terms_codes[0].term_cd
    semesters << {
      :name => semester_name,
      :slug => make_slug(semester_name),
      :is_current => true,
      :schedule => schedule
    }

    data[:semesters] = semesters
    data[:current_semester_index] = 0
  end
end
