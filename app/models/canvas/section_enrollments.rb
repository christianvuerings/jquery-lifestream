module Canvas
  class SectionEnrollments < Proxy

    ENROLLMENT_STATES = ['active', 'invited']
    ENROLLMENT_TYPES = ["StudentEnrollment", "TeacherEnrollment", "TaEnrollment", "ObserverEnrollment", "DesignerEnrollment"]

    def initialize(options = {})
      super(options)
      raise ArgumentError, "Section ID option required" unless options.has_key?(:section_id)
      @section_id = options[:section_id]
    end

    def list_enrollments(options = {})
      default_options = {:cache => false}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache(@section_id) { request_enrollments_list }
      else
        request_enrollments_list
      end
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
      response = request_uncached request_path, request_options
      JSON.parse(response.body)
    end

    private

    # Returns all of the enrollments in the section
    # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.index
    def request_enrollments_list
      all_enrollments = []
      params = "per_page=100"
      while params do
        response = request_uncached [request_path, params].join('?')
        break unless (response && response.status == 200 && enrollments_list = safe_json(response.body))
        all_enrollments.concat(enrollments_list)
        params = next_page_params(response)
      end
      all_enrollments
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get).
        respond_with_file('fixtures', 'json', 'canvas_section_enrollments.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :post).
        respond_with_file('fixtures', 'json', 'canvas_section_enroll_user.json')
    end

    def request_path
      "sections/#{@section_id}/enrollments"
    end

  end
end
