module Canvas
  class WebcastEligibleCourses
    include ClassLogger

    def initialize(sis_term_ids, options = {})
      @sis_term_ids = sis_term_ids
      @options = options
      @webcast_enabled_rooms = Webcast::Rooms.new @options
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
                  courses_by_term[key][canvas_course_id] ||= []
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
      webcast_enabled_room_ccn_set = %w(2015-B-65560 2015-B-5762)
      courses_by_term.each do |key, courses|
        ccn_set = extract_ccn_set courses
        recordings_per_ccn = Webcast::CourseMedia.new(key[:term_yr], key[:term_cd], ccn_set, @options).get_feed
        courses.each do |canvas_course_id, sections|
          sections.each do |section|
            ccn = section[:ccn].to_s.to_i
            if ccn > 0
              section_key = "#{key[:term_yr]}-#{key[:term_cd]}-#{ccn}"
              has_recordings = recordings_per_ccn.has_key?(section_key) && recordings_per_ccn[section_key][:videos].present?
              logger.warn "#{section_key} has Webcast recordings (canvas_course_id = #{canvas_course_id})" if has_recordings
              in_webcast_enabled_room = webcast_enabled_room_ccn_set.include? section_key
              if has_recordings || in_webcast_enabled_room
                section[:has_webcast_recordings] = has_recordings
                section[:in_webcast_enabled_room] = in_webcast_enabled_room
                eligible_courses[canvas_course_id] ||= []
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
