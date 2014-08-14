module MyAcademics
  class Semesters
    include AcademicsModule

    def initialize(uid)
      super(uid)
    end

    def merge(data)
      proxy = CampusOracle::UserCourses::All.new({:user_id => @uid})
      feed = proxy.get_all_campus_courses
      transcripts = CampusOracle::UserCourses::Transcripts.new({:user_id => @uid}).get_all_transcripts
      semesters = []

      feed.keys.each do |term_key|
        (term_yr, term_cd) = term_key.split("-")
        semester = semester_info(term_yr, term_cd)
        feed[term_key].each do |course|
          next unless course[:role] == 'Student'
          class_item = class_info(course)
          class_item[:sections].each do |section|
            if section[:is_primary_section]
              section[:gradeOption] = Berkeley::GradeOptions.grade_option_for_enrollment(section[:cred_cd], section[:pnp_flag])
              section[:units] = section[:unit]
            end
          end
          class_item[:transcript] = find_transcript_data(transcripts, term_yr, term_cd, course[:dept], course[:catid])
          semester[:classes] << class_item
        end
        semesters << semester unless semester[:classes].empty?
      end

      data[:semesters] = semesters
    end

    def find_transcript_data(transcripts, term_yr, term_cd, dept_name, catalog_id)
      matching_transcripts = transcripts.select do |t|
        t['term_yr'] == term_yr &&
          t['term_cd'] == term_cd &&
          t['dept_name'] == dept_name &&
          t['catalog_id'] == catalog_id
      end
      if matching_transcripts.present?
        matching_transcripts.collect do |t|
          {
            units: t['transcript_unit'],
            grade: t['grade']
          }
        end
      else
        nil
      end
    end
  end
end
