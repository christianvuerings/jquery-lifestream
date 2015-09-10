module CanvasLti
  class CourseAddUser
    include SafeJsonParser
    include ClassLogger

    SEARCH_TYPES = %w(name email ldap_user_id)
    SEARCH_LIMIT = 20

    ENROLLMENT_TYPE_TO_DEFAULT_ROLE_LABEL = {
      'DesignerEnrollment' => 'Designer',
      'ObserverEnrollment' => 'Observer',
      'StudentEnrollment' => 'Student',
      'TaEnrollment' => 'TA',
      'TeacherEnrollment' => 'Teacher'
    }

    def initialize(options = {})
      raise ArgumentError, 'Course ID must be a Fixnum' if options[:canvas_course_id].class != Fixnum
      @user_id = options[:user_id]
      @canvas_course_id = options[:canvas_course_id]
      canvas_user_profile = Canvas::SisUserProfile.new(user_id: @user_id).get
      @canvas_user_id = canvas_user_profile['id']
    end

    def self.search_users(search_text, search_type)
      raise ArgumentError, 'Search text must be of type String' if search_text.class != String
      raise ArgumentError, 'Search type must be of type String' if search_type.class != String
      sentence_options = {:last_word_connector => ', or ', :two_words_connector => ' or '}
      raise ArgumentError, "Search type argument '#{search_type}' invalid. Must be #{SEARCH_TYPES.to_sentence(sentence_options)}" unless SEARCH_TYPES.include?(search_type)
      case search_type
        when 'name'
          people = CampusOracle::Queries.find_people_by_name(search_text, SEARCH_LIMIT)
        when 'email'
          people = CampusOracle::Queries.find_people_by_email(search_text, SEARCH_LIMIT)
        when 'ldap_user_id'
          people = CampusOracle::Queries.find_people_by_uid(search_text)
      end
      people.collect! do |person|
        if person['affiliations'].present? && person['affiliations'].include?('-TYPE-')
          person.delete('student_id')
          HashConverter.camelize(person)
        end
      end
      people.compact
    end

    def course_sections_list
      canvas_course_sections_proxy = Canvas::CourseSections.new(course_id: @canvas_course_id)
      sections_response = canvas_course_sections_proxy.sections_list
      if (sections = sections_response[:body])
        sections.collect { |section| {'id' => section['id'].to_s, 'name' => section['name']} }
      end
    end

    def add_user_to_course_section(ldap_user_id, role_id, canvas_course_section_id)
      canvas_user_profile = Canvas::SisUserProfile.new(user_id: ldap_user_id).get
      if canvas_user_profile.nil?
        CanvasCsv::UserProvision.new.import_users [ldap_user_id]
        Canvas::SisUserProfile.expire(ldap_user_id)
        canvas_user_profile = Canvas::SisUserProfile.new(user_id: ldap_user_id).get
      end
      canvas_section_enrollments_proxy = Canvas::SectionEnrollments.new(:section_id => canvas_course_section_id)
      canvas_section_enrollments_proxy.enroll_user(canvas_user_profile['id'], role_id)
      true
    end

    def add_user_to_course(ldap_user_id, role_label)
      canvas_user_profile = Canvas::SisUserProfile.new(user_id: ldap_user_id.to_s).get
      role = (defined_course_roles.select {|r| r['label'] == role_label}).first
      if role.present?
        enrollments_proxy = Canvas::CourseEnrollments.new(:user_id => ldap_user_id.to_s, :canvas_course_id => @canvas_course_id.to_i)
        enrollment_response = enrollments_proxy.enroll_user(canvas_user_profile['id'], role['id'])
        enrollment_response[:body]
      end
    end

    # For reasons lost in time, the Canvas course enrollments API returns enrollment type in place of role label
    # for the built-in membership roles. We need to undo that in our own code.
    def roles_to_labels(profile)
      roles = []
      if profile.present? && profile['enrollments'].present?
        raw_roles = profile['enrollments'].collect {|enrollment| enrollment['role'] }
        raw_roles.each do |role|
          if ENROLLMENT_TYPE_TO_DEFAULT_ROLE_LABEL[role]
            roles << ENROLLMENT_TYPE_TO_DEFAULT_ROLE_LABEL[role]
          else
            roles << role
          end
        end
      end
      roles
    end

    def authorization_profile
      course_user = Canvas::CourseUser.new(user_id: @canvas_user_id, course_id: @canvas_course_id).course_user
      course_user_roles = roles_to_labels course_user
      global_admin = Canvas::Admins.new.admin_user?(@user_id)
      course_user_roles << 'globalAdmin' if global_admin
      if course_user.present? && course_user['enrollments'].present?
        course_user_role_types = course_user['enrollments'].collect {|enrollment| enrollment['type'] }
      else
        course_user_role_types = []
      end
      granting_roles_and_ids = granting_roles_map(course_user_roles)
      {
        roles: course_user_roles,
        roleTypes: course_user_role_types,
        granting_roles_and_ids: granting_roles_and_ids
      }
    end

    # See output of Canvas::CourseUser#roles for course_user_roles argument
    def granting_roles_map(course_user_roles)
      defined_roles = defined_course_roles

      # Find the highest level access granted by the user's current roles.
      if course_user_roles.include? 'globalAdmin'
        can_manage_admin_users = true
        can_manage_students = true
      else
        course_user_roles.each do |user_role|
          can_manage_admin_users = false
          can_manage_students = false
          if (role_definition = defined_roles.select {|r| r['label'] == user_role}.first)
            can_manage_students = true if role_definition['permissions']['manage_students']['enabled']
            can_manage_admin_users = true if role_definition['permissions']['manage_admin_users']['enabled']
          end
        end
      end

      grantable_enrollment_types = []
      if can_manage_students
        grantable_enrollment_types.concat ['StudentEnrollment', 'ObserverEnrollment']
      end
      if can_manage_admin_users
        grantable_enrollment_types.concat ['DesignerEnrollment', 'TaEnrollment', 'TeacherEnrollment']
      end

      # Find the defined roles which correspond to the grantable enrollment types.
      granting_roles_and_ids = {}
      defined_roles.each do |defined_role|
        if grantable_enrollment_types.include? defined_role['base_role_type']
          granting_roles_and_ids[defined_role['label']] = defined_role['id']
        end
      end
      granting_roles_and_ids
   end

    def defined_course_roles
      course_data = Canvas::Course.new(canvas_course_id: @canvas_course_id).course
      if course_data.present? && course_data[:body].present? && (account_id = course_data[:body]['account_id'])
        Canvas::AccountRoles.new(account_id: account_id).defined_course_roles
      else
        []
      end
    end

  end
end
