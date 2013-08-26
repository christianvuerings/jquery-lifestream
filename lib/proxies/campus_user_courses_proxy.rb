class CampusUserCoursesProxy < BaseProxy
  extend Proxies::EnableForActAs

  APP_ID = "Campus"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
    @uid = @settings.fake_user_id if @fake
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def current_terms
    @settings.current_terms_codes
  end

  def get_all_campus_courses
    # Because this data structure is used by multiple top-level feeds, it's essential
    # that it be cached efficiently.
    self.class.fetch_from_cache "all-courses-#{@uid}" do
      campus_classes = {}
      previous_item = {}

      enrollments = CampusData.get_enrolled_sections(@uid)
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
      assigneds = CampusData.get_instructing_sections(@uid)
      assigneds.each do |row|
        if (item = row_to_feed_item(row, previous_item))
          item[:role] = 'Instructor'
          item[:site_url] = nil
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

  # Example:
  # {
  #    "id": "COG SCI:C102:2013-B",
  #    "course_code": "COG SCI C102",
  #    "site_url": "/academics/semester/spring-2013/class/12345",
  #    "emitter": "Campus",
  #    "name": "Scientific Approaches to Consciousness",
  #    "color_class": "campus-class",
  #    "term_yr": "2013",
  #    "term_cd": "B",
  #    "dept": "COG SCI",
  #    "catid": "C102",
  #    "sections": [
  #      {"ccn": "12345", "instruction_format": "LEC", "section_num": "001",
  #        "schedules": [], "instructors": [{"name": "Dr. X", "uid": "999"}]},
  #      {"ccn": "12346", "instruction_format": "DIS", "section_num": "101",
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

  def row_to_feed_item(row, previous_item)
    course_id = "#{row['dept_name']}:#{row['catalog_id']}:#{row['term_yr']}-#{row['term_cd']}"
    if course_id == previous_item[:id]
      previous_item[:sections] << {
          ccn: row['course_cntl_num'],
          instruction_format: row['instruction_format'],
          section_num: row['section_num']
      }
      nil
    else
      {
          id: course_id,
          term_yr: row['term_yr'],
          term_cd: row['term_cd'],
          dept: row['dept_name'],
          catid: row['catalog_id'],
          course_code: "#{row['dept_name']} #{row['catalog_id']}",
          site_url: course_to_url(row['term_cd'], row['term_yr'], row['dept_name'], row['course_cntl_num']),
          emitter: 'Campus',
          name: row['course_title'],
          color_class: "campus-class",
          sections: [
              {
                  ccn: row['course_cntl_num'],
                  instruction_format: row['instruction_format'],
                  section_num: row['section_num']
              }
          ]
      }
    end
  end

  # Link campus courses to internal class pages for the current semester.
  # TODO: Update to use full class IDs, not just CCNs
  def course_to_url(term_cd, term_year, department, ccn)
    term = case term_cd
             when 'B' then 'spring'
             when 'C' then 'summer'
             when 'D' then "fall"
             else
               Rails.logger.warn("Unknown term code #{term_cd} for #{department} #{ccn}")
               return ''
           end
    "/academics/semester/#{term}-#{term_year}/class/#{ccn}"
  end

end
