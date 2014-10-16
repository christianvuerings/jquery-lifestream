module Canvas
  # Prepares CSV export of official enrollments for use with E-Grades (UCB Online Grading System)
  #
  # All grades/scores for students enrolled in the Canvas course are prepared by #canvas_course_students
  # #official_student_grades provides only the grades for the students officially enrolled in the section term/ccn specified.
  #
  class Egrades

    def initialize(options = {})
      raise RuntimeError, "canvas_course_id required" unless options.include?(:canvas_course_id)
      raise RuntimeError, "user_id required" unless options.include?(:user_id)
      @user_id = options[:user_id]
      @canvas_course_id = options[:canvas_course_id]
    end

    def official_student_grades_csv(term_cd, term_yr, ccn)
      official_students = official_student_grades(term_cd, term_yr, ccn)
      CSV.generate do |csv|
        csv << ['uid','grade','comment']
        official_students.each do |student|
          uid = student[:sis_login_id]
          grade = student[:final_grade]
          csv << [uid, grade, '']
        end
      end
    end

    def official_student_grades(term_cd, term_yr, ccn)
      enrolled_students = CampusOracle::Queries.get_enrolled_students(ccn, term_yr, term_cd)
      enrollee_ldap_uid_set = enrolled_students.collect {|student| student['ldap_uid'] }.to_set
      official_students = canvas_course_students.select {|student| enrollee_ldap_uid_set.include?(student[:sis_login_id]) }
    end

    def canvas_course_students
      proxy = Canvas::CourseUsers.new(:user_id => @user_id, :course_id => @canvas_course_id)
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
          :final_grade => user_grade[:final_grade]
        }
      end
      course_students
    end

    # Extracts final score and grade from enrollments
    def student_grade(enrollments)
      grade = { :final_score => nil, :final_grade => nil }
      return grade if enrollments.to_a.empty?
      enrollments.reject! {|e| e['type'] != 'StudentEnrollment' || !e.include?('grades') }
      return grade if enrollments.to_a.empty?
      grades = enrollments[0]['grades']
      # multiple student enrollments carry identical grades for course user in canvas
      grade[:final_score] = grades['final_score'] if grades.include?('final_score')
      grade[:final_grade] = grades['final_grade'] if grades.include?('final_grade')
      grade
    end

    # Indicates if current Canvas grades include letter and/or numeric grades
    def grade_types_present
      grade_indicators = { :number_grades_present => false, :letter_grades_present => false }
      canvas_course_students.each do |student|
        grade_indicators[:number_grades_present] = true if student[:final_score].present?
        grade_indicators[:letter_grades_present] = true if student[:final_grade].present?
      end
      grade_indicators
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
      get_official_section_identifiers = Proc.new {
        canvas_course_sections_proxy = Canvas::CourseSections.new(:user_id => @user_id, :course_id => @canvas_course_id)
        sections_response = canvas_course_sections_proxy.sections_list
        return [] unless sections_response && sections_response.status == 200
        course_sections = JSON.parse(sections_response.body)
        course_sections.reject! {|s| !s.include?('sis_section_id') || s['sis_section_id'].blank? }
        course_sections.collect! {|s| Canvas::Proxy.sis_section_id_to_ccn_and_term(s['sis_section_id']) }
        course_sections.compact
      }
      @official_section_ids ||= get_official_section_identifiers.call
    end

  end
end

