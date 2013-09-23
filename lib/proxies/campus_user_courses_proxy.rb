class CampusUserCoursesProxy < BaseProxy
  extend Proxies::EnableForActAs

  APP_ID = "Campus"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
    @uid = @settings.fake_user_id if @fake
  end

  def self.expires_in
    self.bearfacts_derived_expiration
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def current_terms
    @settings.current_terms_codes
  end

  def academic_terms
    @settings.academic_terms
  end

  def get_all_campus_courses
    # Because this data structure is used by multiple top-level feeds, it's essential
    # that it be cached efficiently.
    self.class.fetch_from_cache "all-courses-#{@uid}" do
      campus_classes = {}
      previous_item = {}

      enrollments = CampusData.get_enrolled_sections(@uid, academic_terms.student)
      enrollments.each do |row|
        if (item = row_to_feed_item(row, previous_item))
          item[:role] = 'Student'
          item[:unit] = row['unit']
          item[:pnp_flag] = row['pnp_flag']
          item[:grade] = row["grade"]
          item[:transcript_unit] = row["transcript_unit"]
          if row['enroll_status'] == 'W'
            item[:waitlist_pos] = row['wait_list_seq_num']
            item[:enroll_limit] = row['enroll_limit']
          end
          semester_key = "#{item[:term_yr]}-#{item[:term_cd]}"
          campus_classes[semester_key] ||= []
          campus_classes[semester_key] << item
          previous_item = item
        end
      end

      previous_item = {}
      assigneds = CampusData.get_instructing_sections(@uid, academic_terms.instructor)
      assigneds.each do |row|
        if (item = row_to_feed_item(row, previous_item))
          item[:role] = 'Instructor'
          semester_key = "#{item[:term_yr]}-#{item[:term_cd]}"
          campus_classes[semester_key] ||= []
          campus_classes[semester_key] << item
          previous_item = item
        end
      end

      campus_classes.values.each do |semester|
        semester.each do |course|
          course[:sections].each do |section|
            proxy = CampusCourseSectionsProxy.new({term_yr: course[:term_yr],
                                                   term_cd: course[:term_cd],
                                                   ccn: section[:ccn]})
            section.merge!(proxy.get_section_data)
          end
        end
      end

      campus_classes
    end
  end

  def get_all_transcripts
    self.class.fetch_from_cache "all-transcripts-#{@uid}" do
      CampusData.get_transcript_grades(@uid, academic_terms.student)
    end
  end

  # Example:
  # {
  #    "id": "COG_SCI-C102-2013-B",
  #    "course_code": "COG SCI C102",
  #    "emitter": "Campus",
  #    "name": "Scientific Approaches to Consciousness",
  #    "color_class": "campus-class",
  #    "term_yr": "2013",
  #    "term_cd": "B",
  #    "dept": "COG SCI",
  #    "catid": "C102",
  #    "sections": [
  #      {"ccn": "12345", "instruction_format": "LEC", "section_number": "001",
  #        "schedules": [], "instructors": [{"name": "Dr. X", "uid": "999"}]},
  #      {"ccn": "12346", "instruction_format": "DIS", "section_number": "101",
  #        "schedules": [], "instructors": [{"name": "Gee Esai", "uid": "1111"}]}
  #    ]
  #    "role": "Student", (or "Instructor")
  #    "waitlist_pos": 2
  # },
  def get_campus_courses
    self.class.fetch_from_cache @uid do
      all_courses = get_all_campus_courses
      campus_classes = []

      current_terms.each do |term|
        semester_key = "#{term.term_yr}-#{term.term_cd}"
        if all_courses[semester_key]
          all_courses[semester_key].each do |course|
            campus_classes << course
          end
        end
      end
      campus_classes
    end
  end

  def has_student_history?
    self.class.fetch_from_cache @uid do
      CampusData.has_student_history?(@uid, academic_terms.student)
    end
  end

  def has_instructor_history?
    self.class.fetch_from_cache @uid do
      CampusData.has_instructor_history?(@uid, academic_terms.instructor)
    end
  end

  def row_to_feed_item(row, previous_item)
    course_id = "#{row['dept_name']}-#{row['catalog_id']}-#{row['term_yr']}-#{row['term_cd']}"
    # Make it embeddable as an element in a URL path.
    course_id = course_id.downcase.gsub(/[^a-z0-9-]+/, '_')
    if course_id == previous_item[:id]
      previous_item[:sections] << row_to_section_data(row)
      nil
    else
      {
          id: course_id,
          term_yr: row['term_yr'],
          term_cd: row['term_cd'],
          dept: row['dept_name'],
          catid: row['catalog_id'],
          course_code: "#{row['dept_name']} #{row['catalog_id']}",
          emitter: 'Campus',
          name: row['course_title'],
          color_class: "campus-class",
          sections: [
            row_to_section_data(row)
          ]
      }
    end
  end

  def row_to_section_data(row)
    section_data = {
        ccn: row['course_cntl_num'],
        instruction_format: row['instruction_format'],
        is_primary_section: (row['primary_secondary_cd'] == 'P'),
        section_label: "#{row['instruction_format']} #{row['section_num']}",
        section_number: row['section_num']
    }
    # This only applies to enrollment records and will be skipped for instructors.
    if row['enroll_status'] == 'W'
      section_data[:waitlist_position] = row['wait_list_seq_num']
      section_data[:enroll_limit] = row['enroll_limit']
    end
    section_data
  end

end
