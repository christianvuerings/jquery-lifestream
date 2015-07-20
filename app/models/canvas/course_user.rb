module Canvas
  class CourseUser < Proxy

    ADMIN_ROLES = %w(TeacherEnrollment TaEnrollment DesignerEnrollment Owner Maintainer)

    def initialize(options = {})
      super(options)
      raise ArgumentError, 'User ID option required' unless options.has_key?(:user_id)
      raise ArgumentError, 'User ID option must be a Fixnum' if options[:user_id].class != Fixnum
      raise ArgumentError, 'Course ID option required' unless options.has_key?(:course_id)
      raise ArgumentError, 'Course ID option must be a Fixnum' if options[:course_id].class != Fixnum
      @user_id = options[:user_id]
      @course_id = options[:course_id]
    end

    def course_user(options = {})
      response = optional_cache(options, key: "#{@course_id}/#{@user_id}", default: true) { user_response }
      response[:body] if response[:statusCode] < 400
    end

    def self.is_course_admin?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if ADMIN_ROLES.include?(enrollment['role'])
      end
      false
    end

    def self.is_course_teacher?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if enrollment['role'] == 'TeacherEnrollment'
      end
      false
    end

    def self.is_course_teachers_assistant?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if enrollment['role'] == 'TaEnrollment'
      end
      false
    end

    def roles
      profile = course_user
      roles_hash = {'teacher' => false, 'student' => false, 'waitlistStudent' => false, 'observer' => false, 'designer' => false, 'ta' => false, 'owner' => false, 'maintainer' => false, 'member' => false}
      return roles_hash if profile.nil? || profile['enrollments'].nil? || profile['enrollments'].empty?
      roles = profile['enrollments'].collect {|enrollment| enrollment['role'] }
      roles_hash['student'] = true if roles.include?('StudentEnrollment')
      roles_hash['teacher'] = true if roles.include?('TeacherEnrollment')
      roles_hash['observer'] = true if roles.include?('ObserverEnrollment')
      roles_hash['ta'] = true if roles.include?('TaEnrollment')
      roles_hash['designer'] = true if roles.include?('DesignerEnrollment')
      roles_hash['waitlistStudent'] = true if roles.include?('Waitlist Student')
      roles_hash['owner'] = true if roles.include?('Owner')
      roles_hash['maintainer'] = true if roles.include?('Maintainer')
      roles_hash['member'] = true if roles.include?('Member')
      roles_hash
    end

    def role_types
      profile = course_user
      return [] if profile.nil? || profile['enrollments'].nil? || profile['enrollments'].empty?
      profile['enrollments'].collect {|enrollment| enrollment['type'] }
    end

    def user_response
      wrapped_get request_path
    end

    # Do not need to log a stack trace when the user is not a course site member.
    def existence_check
      true
    end

    private

    # Interface to request a single user in a course
    # See https://canvas.instructure.com/doc/api/courses.html#method.courses.user
    def request_path
      "courses/#{@course_id}/users/#{@user_id}?include[]=enrollments"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_course_user.json')
    end
  end
end
