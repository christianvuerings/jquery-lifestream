module Canvas
  class CourseAssignments < Proxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    # Interface to request all assignments in a course
    # See https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
    def course_assignments
      assignments_response[:body]
    end

    def muted_assignments
      course_assignments.select do |assignment|
        assignment['muted'] == true
      end
    end

    def unmute_assignment(canvas_assignment_id)
      wrapped_put "#{request_path}/#{canvas_assignment_id}", {
        'assignment' => {
          'muted' => false
        }
      }
    end

    def assignments_response
      paged_get request_path
    end

    private

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', "canvas_course_assignments_#{@course_id}.json")

      on_request(uri_matching: "#{api_root}/#{request_path}/", method: :put)
        .respond_with_file('fixtures', 'json', 'canvas_course_assignment_unmute.json')
    end

    def request_path
      "courses/#{@course_id}/assignments"
    end
  end
end
