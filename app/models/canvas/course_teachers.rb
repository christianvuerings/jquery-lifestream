module Canvas
  class CourseTeachers < Proxy

    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def full_teachers_list
      self.class.fetch_from_cache @course_id do
        all_teachers = []
        params = "enrollment_type=teacher&include[]=enrollments&per_page=30"
        while params do
          response = request_uncached "#{request_path}?#{params}"
          break unless (response && response.status == 200 && teachers_list = safe_json(response.body))
          all_teachers.concat(teachers_list)
          params = next_page_params(response)
        end
        all_teachers
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
