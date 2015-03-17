module MyAcademics
  class Semesters
    include AcademicsModule

    def initialize(uid)
      super(uid)
    end

    def merge(data)
      enrollments = CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
      transcripts = CampusOracle::UserCourses::Transcripts.new(user_id: @uid).get_all_transcripts

      data[:additionalCredits] = transcripts[:additional_credits] if transcripts[:additional_credits].any?
      data[:semesters] = semester_feed(enrollments, transcripts[:semesters]).compact
    end

    def semester_feed(enrollment_terms, transcript_terms)
      (enrollment_terms.keys | transcript_terms.keys).sort.reverse.map do |term_key|
        semester = semester_info term_key
        if enrollment_terms[term_key]
          semester[:hasEnrollmentData] = true
          semester[:classes] = map_enrollments(enrollment_terms[term_key]).compact
          merge_grades(semester, transcript_terms[term_key])
        else
          semester[:hasEnrollmentData] = false
          semester[:classes] = map_transcripts transcript_terms[term_key][:courses]
          semester[:notation] = translate_notation transcript_terms[term_key][:notations]
        end
        semester unless semester[:classes].empty?
      end
    end

    def map_enrollments(enrollment_term)
      enrollment_term.map do |course|
        next unless course[:role] == 'Student'
        mapped_course = course_info course
        mapped_course[:sections].each do |section|
          if section[:is_primary_section]
            section[:gradeOption] = Berkeley::GradeOptions.grade_option_for_enrollment(section[:cred_cd], section[:pnp_flag])
          end
        end
        mapped_course
      end
    end

    def map_transcripts(transcript_courses)
      return [] if !transcript_courses
      transcript_courses.map do |course|
        course.slice(:title, :dept, :courseCatalog).merge({
          course_code: [course[:dept], course[:courseCatalog]].select(&:present?).join(' '),
          transcript: [course.slice(:units, :grade)]
        })
      end
    end

    def merge_grades(semester, transcript_term)
      semester[:classes].each do |course|
        grade_sources = nil
        if use_enrollment_grades?(semester)
          grade_sources = course[:sections].select { |s| s[:is_primary_section] && s[:grade] }
        elsif use_transcript_grades?(semester) && transcript_term
          grade_sources = transcript_term[:courses].select { |t| t[:dept] == course[:dept] && t[:courseCatalog] == course[:courseCatalog] }
        end
        course[:transcript] = grade_sources.map { |e| e.slice(:units, :grade) } if grade_sources.present?
      end
    end

    def translate_notation(transcript_notations)
      return unless transcript_notations
      if transcript_notations.include? 'extension'
        'UC Extension'
      elsif transcript_notations.include? 'abroad'
        'Education Abroad'
      end
    end

    def use_enrollment_grades?(semester)
      semester[:timeBucket] == 'current' || semester[:gradingInProgress]
    end

    def use_transcript_grades?(semester)
      semester[:timeBucket] == 'past' && !semester[:gradingInProgress]
    end

  end
end
