module Canvas
  class Course < Proxy

    attr_accessor :canvas_course_id

    def initialize(options = {})
      super(options)
      @canvas_course_id = options[:canvas_course_id]
    end

    def course(options = {})
      optional_cache(options, key: @canvas_course_id.to_s, default: true) { wrapped_get request_path }
    end

    def create(account_id, course_name, course_code, term_id, sis_course_id)
      wrapped_post "accounts/#{account_id}/courses", {
        'account_id' => account_id,
        'course' => {
          'name' => course_name,
          'course_code' => course_code,
          'term_id' => term_id,
          'sis_course_id' => sis_course_id
        }
      }
    end

    private

    def request_path
      "courses/#{@canvas_course_id}?include[]=term"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_course.json')
    end

  end
end
