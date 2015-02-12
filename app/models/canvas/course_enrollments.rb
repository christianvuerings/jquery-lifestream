module Canvas
  class CourseEnrollments < Proxy

    ENROLLMENT_STATES = ['active', 'invited']
    ENROLLMENT_TYPES = ['StudentEnrollment', 'TeacherEnrollment', 'TaEnrollment', 'ObserverEnrollment', 'DesignerEnrollment']

    def initialize(options = {})
      super(options)
      raise ArgumentError, 'Canvas Course ID option required' unless options.has_key?(:canvas_course_id)
      @canvas_course_id = options[:canvas_course_id]
    end

    # Interface to Enroll a User in a Canvas Course
    # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
    # Include 'role_id' option to specify custom roles (i.e. Waitlist Student, Owner, Maintainer, Member)
    def enroll_user(canvas_user_id, enrollment_type, enrollment_state, notify = false, options = {})
      raise ArgumentError, 'Notification flag must be a Boolean' unless notify == true || notify == false
      sentence_options = {:last_word_connector => ', or ', :two_words_connector => ' or '}
      raise ArgumentError, "Enrollment type argument '#{enrollment_type}', must be #{ENROLLMENT_TYPES.to_sentence(sentence_options)}" unless ENROLLMENT_TYPES.include?(enrollment_type.to_str)
      raise ArgumentError, "Enrollment state argument '#{enrollment_state}', must be #{ENROLLMENT_STATES.to_sentence(sentence_options)}" unless ENROLLMENT_STATES.include?(enrollment_state.to_str)
      request_params = {
        'enrollment' => {
          'user_id' => canvas_user_id.to_int,
          'type' => enrollment_type.to_str,
          'enrollment_state' => enrollment_state.to_str,
          'notify' => !!notify,
        }
      }
      request_params['enrollment'].merge!({'role_id' => options[:role_id]}) if options[:role_id]
      request_options = {
        :method => :post,
        :body => request_params,
      }
      response = request_uncached("courses/#{@canvas_course_id}/enrollments", '_course_enroll_user', request_options)
      JSON.parse(response.body)
    end

  end
end
