module Canvas
  class CourseAddUser

    SEARCH_TYPES = ['name', 'email', 'ldap_user_id']

    SEARCH_LIMIT = 20

    def self.search_users(search_text, search_type)
      raise ArgumentError, "Search text must of type String" if search_text.class != String
      raise ArgumentError, "Search type must of type String" if search_type.class != String
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
        person.delete('student_id')
        person
      end
      people
    end

    def self.course_sections_list(course_id)
      raise ArgumentError, "Course ID must be a Fixnum" if course_id.class != Fixnum
      canvas_course_sections_proxy = Canvas::CourseSections.new(course_id: course_id)
      sections_response = canvas_course_sections_proxy.sections_list
      sections = JSON.parse(sections_response.body)
      sections.collect { |section| {'id' => section['id'].to_s, 'name' => section['name']} }
    end

    def self.add_user_to_course_section(ldap_user_id, role, canvas_course_section_id)
      raise ArgumentError, "ldap_user_id must be a String" if ldap_user_id.class != String
      raise ArgumentError, "role must be a String" if role.class != String
      Canvas::UserProvision.new.import_users([ldap_user_id])
      canvas_user_profile = Canvas::SisUserProfile.new(user_id: ldap_user_id).get
      canvas_section_enrollments_proxy = Canvas::SectionEnrollments.new(:section_id => canvas_course_section_id)
      canvas_section_enrollments_proxy.enroll_user(canvas_user_profile['id'], role, 'active', false)
      true
    end

    def self.granting_roles(course_user_roles, global_admin = false)
      user_roles = course_user_roles.to_hash.select {|key,role| role }.keys
      granted_roles = []
      ta_roles = [
        {'id' => 'StudentEnrollment', 'name' => 'Student'},
        {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
      ]
      privileged_roles = [
        {'id' => 'DesignerEnrollment', 'name' => 'Designer'},
        {'id' => 'TaEnrollment', 'name' => 'TA'},
        {'id' => 'TeacherEnrollment', 'name' => 'Teacher'},
      ]
      granted_roles += ta_roles if user_roles.include?('ta') || user_roles.include?('teacher') || user_roles.include?('designer') || global_admin
      granted_roles += privileged_roles if user_roles.include?('teacher') || user_roles.include?('designer') || global_admin
      return granted_roles
    end

  end
end
