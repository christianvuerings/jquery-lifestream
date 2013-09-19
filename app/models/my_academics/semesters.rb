class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def initialize(uid)
    super(uid)
    @current_term = Settings.sakai_proxy.current_terms_codes[0]
  end

  def merge(data)
    proxy = CampusUserCoursesProxy.new({:user_id => @uid})
    feed = proxy.get_all_campus_courses
    transcripts = proxy.get_all_transcripts
    semesters = []

    feed.keys.each do |term_key|
      (term_yr, term_cd) = term_key.split("-")
      semester = {
          name: TermCodes.to_english(term_yr, term_cd),
          slug: TermCodes.to_slug(term_yr, term_cd),
          time_bucket: time_bucket(term_yr, term_cd),
          classes: []
      }
      feed[term_key].each do |course|
        next unless course[:role] == 'Student'

        # If we have a transcript unit, it needs to trump the unit.
        transcript = find_transcript_data(transcripts, term_yr, term_cd, course[:dept], course[:catid])
        units = transcript[:transcript_unit] ? transcript[:transcript_unit] : course[:unit]

        if course[:pnp_flag].present?
          grade_option = course[:pnp_flag].strip == "Y" ? "P/NP" : "Letter"
        else
          Rails.logger.warn "#{self.class.name} - Course #{course[:course_code]} has a empty 'pnp_flag' field: #{course}"
          grade_option = ''
        end

        class_info = {
            course_number: course[:course_code],
            grade: transcript[:grade],
            grade_option: grade_option,
            slug: course_to_slug(course[:dept], course[:catid]),
            title: course[:name],
            units: units,
            sections: course[:sections]
        }
        semester[:classes] << class_info
      end
      semesters << semester unless semester[:classes].empty?
    end

    data[:semesters] = semesters
  end

  def find_transcript_data(transcripts, term_yr, term_cd, dept_name, catalog_id)
    transcripts.each do |t|
      if t['term_yr'] == term_yr &&
          t['term_cd'] == term_cd &&
          t['dept_name'] == dept_name &&
          t['catalog_id'] == catalog_id
        return {
            transcript_unit: t['transcript_unit'],
            grade: t['grade']
        }
      end
    end
    {}
  end


  def time_bucket(term_yr, term_cd)
    if term_yr < @current_term.term_yr || (term_yr == @current_term.term_yr && term_cd < @current_term.term_cd)
      bucket = 'past'
    elsif term_yr > @current_term.term_yr || (term_yr == @current_term.term_yr && term_cd > @current_term.term_cd)
      bucket = 'future'
    else
      bucket = 'current'
    end
    bucket
  end

end
