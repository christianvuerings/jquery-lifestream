module Canvas
  class CourseTeachers < Proxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def full_teachers_list
      self.class.fetch_from_cache @course_id do
        paged_get request_path, enrollment_type: 'teacher', include: ['email', 'enrollments'], per_page: 100
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'canvas_course_teachers.json')
    end

    def request_path
      "courses/#{@course_id}/users"
    end

  end
end
