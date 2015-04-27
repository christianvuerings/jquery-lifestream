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
        response = request_uncached(
          "courses/#{@course_id}/assignments?#{params}",
          "_course_assignments"
        )
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

  end
end
