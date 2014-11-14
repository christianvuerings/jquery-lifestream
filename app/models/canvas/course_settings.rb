module Canvas
  class CourseSettings < Proxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def settings(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache("#{@canvas_course_id}") { request_settings }
      else
        request_settings
      end
    end

    private

    def request_settings
      response = request_uncached("courses/#{@course_id}/settings", "_course_settings")
      return response ? safe_json(response.body) : nil
    end

  end
end
