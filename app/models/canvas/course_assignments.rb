module Canvas
  class CourseAssignments < Proxy

    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    # Interface to request all assignments in a course
    # See https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
    def course_assignments
      all_assignments = []
      params = "per_page=100"
      while params do
        response = request_uncached "#{request_path}?#{params}"
        break unless (response && response.status == 200 && assignments_list = safe_json(response.body))
        all_assignments.concat(assignments_list)
        params = next_page_params(response)
      end
      all_assignments
    end

    def muted_assignments
      course_assignments.select do |assignment|
        assignment['muted'] == true
      end
    end

    def unmute_assignment(canvas_assignment_id)
      request_params = {
        'assignment' => {
          'muted' => false
        }
      }
      request_options = {
        :method => :put,
        :body => request_params
      }
      response = request_uncached("#{request_path}/#{canvas_assignment_id}", request_options)
      JSON.parse(response.body)
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
