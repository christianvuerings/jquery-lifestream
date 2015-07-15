module Canvas
  class SisCourse < Proxy

    attr_accessor :sis_course_id

    def initialize(options = {})
      super(options)
      @sis_course_id = options[:sis_course_id]
    end

    def course(options = {})
      optional_cache(options, key: @sis_course_id.to_s, default: true) { wrapped_get request_path }
    end

    def canvas_course_id
      course[:body] && course[:body]['id']
    end

    private

    def request_path
      "courses/sis_course_id:#{@sis_course_id}?include[]=term"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_sis_course.json')
    end

  end
end
