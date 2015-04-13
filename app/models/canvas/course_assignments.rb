module Canvas
  class CourseAssignments < Proxy

    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def course_assignments(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache(@course_id) { request_course_assignments }
      else
        request_course_assignments
      end
    end

    private

    # Interface to request all assignments in a course
    # See https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
    def request_course_assignments
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

  end
end
