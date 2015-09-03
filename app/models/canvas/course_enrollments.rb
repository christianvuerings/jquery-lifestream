module Canvas
  class CourseEnrollments < Proxy

    def initialize(options = {})
      super(options)
      raise ArgumentError, 'Canvas Course ID option required' unless options.has_key?(:canvas_course_id)
      @canvas_course_id = options[:canvas_course_id]
    end

    # Interface to Enroll a User in a Canvas Course
    # See https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
    def enroll_user(canvas_user_id, role_id)
      request_params = {
        'enrollment' => {
          'user_id' => canvas_user_id.to_int,
          'role_id' => role_id,
          'enrollment_state' => 'active',
          'notify' => false,
        }
      }
      wrapped_post "courses/#{@canvas_course_id}/enrollments", request_params
    end

  end
end
