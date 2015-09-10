module Canvas
  class SectionEnrollments < Proxy

    def initialize(options = {})
      super(options)
      raise ArgumentError, 'Section ID option required' unless options.has_key?(:section_id)
      @section_id = options[:section_id]
    end

    def list_enrollments(options = {})
      response = optional_cache(options, key: @section_id, default: false) { enrollments_response }
      response[:body]
    end

    # Interface to Enroll a User in Canvas
    # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
    def enroll_user(user_id, role_id)
      raise ArgumentError, 'User ID must be a Fixnum' if user_id.class != Fixnum
      raise ArgumentError, 'Role ID must be a Fixnum' if role_id.class != Fixnum
      wrapped_post request_path, {
        'enrollment' => {
          'user_id' => user_id,
          'role_id' => role_id,
          'enrollment_state' => 'active',
          'course_section_id' => @section_id,
          'notify' => false
        }
      }
    end

    def enrollments_response
      paged_get request_path
    end

    private

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get).
        respond_with_file('fixtures', 'json', 'canvas_section_enrollments.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :post).
        respond_with_file('fixtures', 'json', 'canvas_section_enroll_user.json')
    end

    # Returns all of the enrollments in the section
    # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.index
    def request_path
      "sections/#{@section_id}/enrollments"
    end

  end
end
