module Canvas
  class WebcastEligibleCourses
    include ClassLogger

    def initialize(sis_term_ids, options = {})
      @sis_term_ids = sis_term_ids
      @options = options
    end

    def fetch
      courses_by_term = fetch_term_to_course_sections_hash
      extract_webcast_eligible_courses courses_by_term
    end

    private

    def fetch_term_to_course_sections_hash
      courses_by_term = {}
      @sis_term_ids.each do |term_id|
        canvas_sections = Canvas::SectionsReport.new(@options).get_csv term_id
        if canvas_sections
          course_id_to_csv = canvas_sections.group_by { |row| row['canvas_course_id'] }
          course_id_to_csv.each do |canvas_course_id, csv_rows|
            if canvas_course_id
              sis_section_ids = csv_rows.collect { |row| row['section_id'] }
              sis_section_ids.delete_if { |section| section.blank? }
              sis_section_ids.each do |sis_section_id|
                section = Canvas::Proxy.sis_section_id_to_ccn_and_term sis_section_id
                unless section.nil? || section[:ccn].nil?
                  key = { term_yr: section[:term_yr], term_cd: section[:term_cd] }
                  courses_by_term[key] ||= {}
                  courses_by_term[key][canvas_course_id] ||= Set.new
                  courses_by_term[key][canvas_course_id] << section
                end
              end
            end
          end
        else
          logger.error "No Canvas sections found where term_id = #{term_id}"
        end
      end
      courses_by_term
    end

    def extract_webcast_eligible_courses(courses_by_term)
      eligible_courses = {}
      sign_up_eligible = Webcast::SignUpEligible.new(@options).get
      courses_by_term.each do |key, courses|
        ccn_set = extract_ccn_set courses
        term_yr = key[:term_yr]
        term_cd = key[:term_cd]
        recordings_per_ccn = Webcast::CourseMedia.new(term_yr, term_cd, ccn_set, @options).get_feed
        sign_up_eligible_ccn_set = sign_up_eligible[Berkeley::TermCodes.to_slug(term_yr, term_cd)]
        courses.each do |canvas_course_id, sections|
          sections.each do |section|
            ccn = section[:ccn].to_s.to_i
            if ccn > 0
              has_recordings = recordings_per_ccn.has_key?(ccn) && recordings_per_ccn[ccn][:videos].present?
              logger.warn "#{term_yr}-#{term_cd}-#{ccn} has Webcast recordings (canvas_course_id = #{canvas_course_id})" if has_recordings
              is_webcast_eligible = !has_recordings && !sign_up_eligible_ccn_set.nil? && sign_up_eligible_ccn_set.include?(ccn)
              if has_recordings || is_webcast_eligible
                section[:has_webcast_recordings] = has_recordings
                section[:is_webcast_eligible] = is_webcast_eligible
                eligible_courses[canvas_course_id] ||= Set.new
                eligible_courses[canvas_course_id] << section
              end
            end
          end
        end
      end
      eligible_courses
    end

    def extract_ccn_set(courses)
      ccn_set = Set.new
      courses.values.each do |course|
        course.map { |section| section[:ccn] }.each { |ccn| ccn_set << ccn.to_i }
      end
      ccn_set
    end

  end
end
