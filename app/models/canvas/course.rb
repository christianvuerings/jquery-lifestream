module Canvas
  class Course < Proxy

    attr_accessor :canvas_course_id

    def initialize(options = {})
      super(options)
      @canvas_course_id = options[:canvas_course_id]
    end

    def course(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache("#{@canvas_course_id}") { request_course }
      else
        request_course
      end
    end

    private

    def request_course
      response = request_uncached("courses/#{@canvas_course_id}?include[]=term", "_course")
      return response ? safe_json(response.body) : nil
    end

  end
end
