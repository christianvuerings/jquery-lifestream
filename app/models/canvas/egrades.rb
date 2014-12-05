module Canvas
  # Prepares CSV export of official enrollments for use with E-Grades (UCB Online Grading System)
  #
  # All grades/scores for students enrolled in the Canvas course are prepared by #canvas_course_students
  # #official_student_grades provides only the grades for the students officially enrolled in the section term/ccn specified.
  #
  class Egrades
    extend Cache::Cacheable

    GRADE_TYPES = ['final','current']

    def initialize(options = {})
      raise RuntimeError, "canvas_course_id required" unless options.include?(:canvas_course_id)
      @canvas_course_id = options[:canvas_course_id]
    end

    def official_student_grades_csv(term_cd, term_yr, ccn, type)
      raise ArgumentError, 'type argument must be \'final\' or \'current\'' unless GRADE_TYPES.include?(type)
      official_students = official_student_grades(term_cd, term_yr, ccn)
      CSV.generate do |csv|
        csv << ['student_id','grade','comment']
        official_students.each do |student|
          comment = (student[:pnp_flag] == "Y") ? "Opted for P/NP Grade" : ""
          student_id = student[:student_id]
          grade = student["#{type}_grade".to_sym].to_s
          csv << [student_id, grade, comment]
        end
      end
    end

    def official_student_grades(term_cd, term_yr, ccn)
      enrolled_students = CampusOracle::Queries.get_enrolled_students(ccn, term_yr, term_cd)
      campus_attributes = enrolled_students.index_by {|s| s['ldap_uid']}
      official_students = canvas_course_students.select {|student| campus_attributes[student[:sis_login_id]] }
      official_students.each do |student|
        campus_data = campus_attributes[student[:sis_login_id]]
        student[:pnp_flag] = campus_data['pnp_flag']
        student[:student_id] = campus_data['student_id']
      end
    end

    def canvas_course_students
      proxy = Canvas::CourseUsers.new(:course_id => @canvas_course_id)
      course_users = proxy.course_users(:cache => false)
      course_students = []
      course_users.each do |course_user|
        user_grade = student_grade(course_user['enrollments'])
        course_students << {
          :canvas_course_id => @canvas_course_id,
          :canvas_user_id => course_user['id'],
          :sis_user_id => course_user['sis_user_id'],
          :sis_login_id => course_user['sis_login_id'],
          :name => course_user['name'],
          :final_score => user_grade[:final_score],
          :final_grade => user_grade[:final_grade],
          :current_score => user_grade[:current_score],
          :current_grade => user_grade[:current_grade],
        }
      end
      course_students
    end

    # Extracts scores and grades from enrollments
    def student_grade(enrollments)
      grade = { :current_score => nil, :current_grade => nil, :final_score => nil, :final_grade => nil }
      return grade if enrollments.to_a.empty?
      enrollments.reject! {|e| e['type'] != 'StudentEnrollment' || !e.include?('grades') }
      return grade if enrollments.to_a.empty?
      grades = enrollments[0]['grades']
      # multiple student enrollments carry identical grades for course user in canvas
      grade[:current_score] = grades['current_score'] if grades.include?('current_score')
      grade[:current_grade] = grades['current_grade'] if grades.include?('current_grade')
      grade[:final_score] = grades['final_score'] if grades.include?('final_score')
      grade[:final_grade] = grades['final_grade'] if grades.include?('final_grade')
      grade
    end

    # Provides official sections associated with Canvas course
    def official_sections
      sec_ids = official_section_identifiers
      return [] if sec_ids.empty?
      # A course site can only be provisioned to include sections from a specific term, so all terms should be the same for each section
      term = { :term_yr => sec_ids[0][:term_yr], :term_cd => sec_ids[0][:term_cd] }
      ccns = sec_ids.collect {|sec_id| sec_id[:ccn] }
      sections = CampusOracle::Queries.get_sections_from_ccns(term[:term_yr], term[:term_cd], ccns)
      retained_keys = ['dept_name', 'catalog_id', 'instruction_format', 'primary_secondary_cd', 'section_num', 'term_yr', 'term_cd', 'course_cntl_num']
      sections.collect do |sec|
        filtered_sec = sec.reject {|key, value| !retained_keys.include?(key) }
        filtered_sec['display_name'] = "#{sec['dept_name']} #{sec['catalog_id']} #{sec['instruction_format']} #{sec['section_num']}"
        filtered_sec
      end
    end

    # Returns array of terms associated with Canvas course site
    def section_terms
      official_section_identifiers.collect {|sec_id| sec_id.delete(:ccn); sec_id }.uniq
    end

    # Provides official section identifiers for sections in Canvas course
    def official_section_identifiers
      @official_section_ids ||= Canvas::CourseSections.new(:course_id => @canvas_course_id).official_section_identifiers
    end

    # Returns true if course site contains official sections
    def is_official_course?(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      get_official_course_status = Proc.new {
        (official_section_identifiers.count > 0) ? true : false
      }

      if options[:cache].present?
        self.class.fetch_from_cache("#{@canvas_course_id}") { get_official_course_status.call }
      else
        get_official_course_status.call
      end
    end

  end
end
