class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def initialize(uid)
    super(uid)
  end

  def self.current_term
    Settings.sakai_proxy.current_terms_codes[0]
  end

  def self.build_semester(term_yr, term_cd)
    MyAcademics::AcademicsModule.semester_info(term_yr, term_cd).merge({
      time_bucket: self.time_bucket(term_yr, term_cd),
      classes: []
    })
  end

  def merge(data)
    proxy = CampusUserCoursesProxy.new({:user_id => @uid})
    feed = proxy.get_all_campus_courses
    transcripts = proxy.get_all_transcripts
    semesters = []

    feed.keys.each do |term_key|
      (term_yr, term_cd) = term_key.split("-")
      semester = self.class.build_semester(term_yr, term_cd)
      feed[term_key].each do |course|
        next unless course[:role] == 'Student'

        # If we have a transcript unit, it needs to trump the unit.
        transcript = find_transcript_data(transcripts, term_yr, term_cd, course[:dept], course[:catid])
        units = transcript[:transcript_unit] ? transcript[:transcript_unit] : course[:unit]

        if (course[:cred_cd].present? && course[:cred_cd].strip == "PF") ||
          (course[:pnp_flag].present? && course[:pnp_flag].strip == "Y" && course[:cred_cd].blank?)
          # course specified P/NP option || Student specified P/NP option on a letter grade
          grade_option = "P/NP"
        elsif course[:pnp_flag].present? && course[:cred_cd].present? && course[:cred_cd].strip == "SU"
          grade_option = "S/U"
        elsif course[:pnp_flag].present? && course[:cred_cd].blank?
          grade_option = "Letter"
        else
          Rails.logger.warn "#{self.class.name} - Course #{course[:course_code]} has unknown grading logic:
            course[:cred_cd]: #{course[:cred_cd]}, course[:pnp_flag]: #{course[:pnp_flag]}"
          grade_option = ''
        end

        class_item = class_info(course).merge!({
          grade: transcript[:grade],
          grade_option: grade_option,
          units: units
        })
        semester[:classes] << class_item
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


  def self.time_bucket(term_yr, term_cd)
    if term_yr < self.current_term.term_yr || (term_yr == self.current_term.term_yr && term_cd < self.current_term.term_cd)
      bucket = 'past'
    elsif term_yr > self.current_term.term_yr || (term_yr == self.current_term.term_yr && term_cd > self.current_term.term_cd)
      bucket = 'future'
    else
      bucket = 'current'
    end
    bucket
  end

end
