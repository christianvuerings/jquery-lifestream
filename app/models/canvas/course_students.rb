module Canvas
  class CourseStudents < Proxy
    include PagedProxy
    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def full_students_list
      self.class.fetch_from_cache @course_id do
        all_students = []
        params = "enrollment_type=student&include[]=enrollments&per_page=100"
        while params do
          response = request_uncached "#{request_path}?#{params}"
          break unless (response && response.status == 200 && students_list = safe_json(response.body))
          all_students.concat(students_list)
          params = next_page_params(response)
        end
        all_students
      end
    end

    private

    def mock_interactions
      mock_paged_interaction 'canvas_course_students'
    end

    def request_path
      "courses/#{@course_id}/users"
    end
  end
end
