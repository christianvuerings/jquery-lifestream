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

  # Example:
  # {
  #    "id": "COG SCI:C102:2013-B",
  #    "course_code": "COG SCI C102",
  #    "site_url": "http://osoc.berkeley.edu/OSOC/osoc?p_term=SP&x=0&p_classif=--+Choose+a+Course+Classification+--&p_deptname=--+Choose+a+Department+Name+--&p_presuf=--+Choose+a+Course+Prefix%2fSuffix+--&y=3&p_course=C102&p_dept=COG+SCI",
  #    "emitter": "Campus",
  #    "name": "Scientific Approaches to Consciousness",
  #    "color_class": "campus-class",
  #    "courses": [{
  #      "term_yr": "2013",
  #      "term_cd": "B",
  #      "dept": "COG SCI",
  #      "catid": "C102"
  #    }]
  #    "role": "Student", (or "Instructor")
  #    "waitlist_pos": 2
  # },
  def get_campus_courses()
    self.class.fetch_from_cache @uid do
      campus_classes = []
      previous_id = nil
      current_terms.each do |term|
        term_yr = term.term_yr
        term_cd = term.term_cd
        # The SQL ordering is such that the feed currently only needs the first section record for every
        # course offering. If we later have a need for the full list of sections, they're available.
        enrollments = CampusData.get_enrolled_sections(@uid, term_yr, term_cd)
        enrollments.each do |row|
          if (item = row_to_feed_item(row, previous_id))
            item[:role] = 'Student'
            if row['enroll_status'] == 'W'
              item[:waitlist_pos] = row['wait_list_seq_num']
            end
            campus_classes << item
            previous_id = item[:id]
          end
        end
        assigneds = CampusData.get_instructing_sections(@uid, term_yr, term_cd)
        assigneds.each do |row|
          if (item = row_to_feed_item(row, previous_id))
            item[:role] = 'Instructor'
            campus_classes << item
            previous_id = item[:id]
          end
        end
      end
      campus_classes
    end
  end

  def row_to_feed_item(row, previous_id)
    course_id = "#{row['dept_name']}:#{row['catalog_id']}:#{row['term_yr']}-#{row['term_cd']}"
    if course_id == previous_id
      nil
    else
      {
          id: course_id,
          course_code: "#{row['dept_name']} #{row['catalog_id']}",
          site_url: course_to_url(row['term_cd'], row['dept_name'], row['catalog_id']),
          emitter: 'Campus',
          name: row['course_title'],
          color_class: "campus-class",
          courses: [{
              term_yr: row['term_yr'],
              term_cd: row['term_cd'],
              dept: row['dept_name'],
              catid: row['catalog_id']
          }]
      }
    end
  end

  # To start with, just point to this year's Online Schedule of Classes, since that is semi-predictable and
  # has some useful links.
  def course_to_url(term_cd, department, catalog_id)
    term = case term_cd
             when 'B' then 'SP'
             when 'C' then 'SU'
             when 'D' then "FL"
             else
               Rails.logger.warn("Unknown term code #{term_cd} for #{department} #{catalog_id}")
               return ''
           end
    "http://osoc.berkeley.edu/OSOC/osoc?p_term=" + term +
        "&x=0&p_classif=--+Choose+a+Course+Classification+--&p_deptname=--+Choose+a+Department+Name+--" +
        "&p_presuf=--+Choose+a+Course+Prefix%2fSuffix+--&y=0&p_course=" +
        CGI::escape(catalog_id) + "&p_dept=" + CGI::escape(department)
  end

end