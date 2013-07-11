class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def merge(data)
    proxy = CampusUserCoursesProxy.new({:user_id => @uid})
    feed = proxy.get_campus_courses

    semesters = []
    schedule = []

    feed.each do |course|
      next unless course[:role] == 'Student'
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
      i = 0
      course[:sections].each do |this_section|
        Rails.logger.info "this_section schedules = #{this_section[:schedules]}"
        ccn = this_section[:ccn]
        format = this_section[:instruction_format]
        section = this_section[:section_num]
        section_label = "#{format} #{section}"
        course_label = "#{course_number} #{title}"
        schedules = this_section[:schedules]
        instructors = this_section[:instructors]
        is_primary_section = (i == 0)
        schedule << {
          :course_number => course_number,
          :ccn => ccn,
          :title => title,
          :units => units,
          :grade_option => grade_option,
          :section => section,
          :format => format,
          :section_label => section_label,
          :course_label => course_label,
          :schedules => schedules,
          :instructors => instructors,
          :is_primary_section => is_primary_section
        }
        i += 1
      end

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
