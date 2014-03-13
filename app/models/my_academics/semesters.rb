class MyAcademics::Semesters

  include MyAcademics::AcademicsModule

  def initialize(uid)
    super(uid)
  end

  def self.build_semester(term_yr, term_cd)
    MyAcademics::AcademicsModule.semester_info(term_yr, term_cd).merge({
      time_bucket: MyAcademics::AcademicsModule.time_bucket(term_yr, term_cd),
      classes: []
    })
  end

  def merge(data)
    proxy = CampusOracle::UserCourses.new({:user_id => @uid})
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
        grade_option = Berkeley::GradeOptions.grade_option_for_enrollment(course[:cred_cd], course[:pnp_flag])

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

end
