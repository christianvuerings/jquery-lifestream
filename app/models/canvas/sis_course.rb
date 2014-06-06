module Canvas
  class SisCourse < Proxy

    attr_accessor :sis_course_id

    def initialize(options = {})
      super(options)
      @sis_course_id = options[:sis_course_id]
    end

    def course(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache("#{@sis_course_id}") { request_course }
      else
        request_course
      end
    end

    def canvas_course_id
      course['id']
    end

    private

    def request_course
      response = request_uncached("courses/sis_course_id:#{@sis_course_id}?include[]=term", "_sis_course")
      return response ? safe_json(response.body) : nil
    end

  end
end
