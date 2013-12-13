class CanvasCourseAddUser

  SEARCH_TYPES = ['name','email','student_id','ldap_user_id']

  SEARCH_LIMIT = 20

  def self.search_users(search_text, search_type)
    raise ArgumentError, "Search text must of type String" if search_text.class != String
    raise ArgumentError, "Search type must of type String" if search_type.class != String
    sentence_options = {:last_word_connector => ', or ', :two_words_connector => ' or '}
    raise ArgumentError, "Search type argument '#{search_type}' invalid. Must be #{SEARCH_TYPES.to_sentence(sentence_options)}" unless SEARCH_TYPES.include?(search_type)
    case search_type
      when 'name'
        CampusData.find_people_by_name(search_text, SEARCH_LIMIT)
      when 'email'
        CampusData.find_people_by_email(search_text, SEARCH_LIMIT)
      when 'student_id'
        CampusData.find_people_by_student_id(search_text)
      when 'ldap_user_id'
        CampusData.find_people_by_uid(search_text)
    end
  end

  def self.course_sections_list(course_id)
    raise ArgumentError, "Course ID must be a Fixnum" if course_id.class != Fixnum
    canvas_course_sections_proxy = CanvasCourseSectionsProxy.new(course_id: course_id)
    sections_response = canvas_course_sections_proxy.sections_list
    sections = JSON.parse(sections_response.body)
    sections.collect {|section| {'id' => section['id'].to_s, 'name' => section['name']} }
  end

  def self.add_user_to_course_section(ldap_user_id, role, canvas_course_section_id)
    raise ArgumentError, "ldap_user_id must be a String" if ldap_user_id.class != String
    raise ArgumentError, "role must be a String" if role.class != String
    raise ArgumentError, "canvas_course_section_id must be a String" if canvas_course_section_id.class != String
    CanvasUserProvision.new.import_users([ldap_user_id])
    section_id_num = Integer(canvas_course_section_id, 10)
    canvas_user_profile_response = CanvasUserProfileProxy.new(user_id: ldap_user_id).user_profile
    canvas_user_profile = JSON.parse(canvas_user_profile_response.body)
    canvas_section_enrolmments_proxy = CanvasSectionEnrollmentsProxy.new(:section_id => section_id_num)
    canvas_section_enrolmments_proxy.enroll_user(canvas_user_profile['id'], role, 'active', false)
    true
  end

end
