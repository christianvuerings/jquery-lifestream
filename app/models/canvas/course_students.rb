module Canvas
  class CourseStudents < Proxy
    include PagedProxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def full_students_list
      self.class.fetch_from_cache(@course_id) do
        paged_get request_path, enrollment_type: 'student', include: ['enrollments']
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
