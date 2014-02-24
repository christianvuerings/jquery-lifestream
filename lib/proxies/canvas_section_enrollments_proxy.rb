class CanvasSectionEnrollmentsProxy < CanvasProxy

  ENROLLMENT_STATES = ['active','invited']
  ENROLLMENT_TYPES = ["StudentEnrollment","TeacherEnrollment","TaEnrollment","ObserverEnrollment","DesignerEnrollment"]

  def initialize(options = {})
    super(options)
    raise ArgumentError, "Section ID option required" unless options.has_key?(:section_id)
    raise ArgumentError, "Section ID option must be a Fixnum" if options[:section_id].class != Fixnum
    @section_id = options[:section_id]
  end

  def self.cache_key(section_id)
    "global/#{self.name}/#{section_id}"
  end

  # Interface to Enroll a User in Canvas
  # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
  def enroll_user(user_id, enrollment_type, enrollment_state, notify = false)
    raise ArgumentError, "User ID must be a Fixnum" if user_id.class != Fixnum
    raise ArgumentError, "Enrollment type must be a String" if enrollment_type.class != String
    raise ArgumentError, "Enrollment state must be a String" if enrollment_state.class != String
    raise ArgumentError, "Notification flag must be a Boolean" unless notify == true || notify == false
    sentence_options = {:last_word_connector => ', or ', :two_words_connector => ' or '}
    raise ArgumentError, "Enrollment type argument '#{enrollment_type}', must be #{ENROLLMENT_TYPES.to_sentence(sentence_options)}" unless ENROLLMENT_TYPES.include?(enrollment_type)
    raise ArgumentError, "Enrollment state argument '#{enrollment_state}', must be #{ENROLLMENT_STATES.to_sentence(sentence_options)}" unless ENROLLMENT_STATES.include?(enrollment_state)
    request_params = {
      'enrollment' => {
        'user_id' => user_id,
        'type' => enrollment_type,
        'enrollment_state' => enrollment_state,
        'course_section_id' => @section_id,
        'notify' => notify,
      }
    }
    request_options = {
      :method => :post,
      :body => request_params,
    }
    response = request_uncached("sections/#{@section_id}/enrollments", "_section_enroll_user", request_options)
    JSON.parse(response.body)
  end

end
