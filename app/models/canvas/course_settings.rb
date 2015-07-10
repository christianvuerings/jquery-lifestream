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

    def set_grading_scheme(grading_scheme_id = nil)
      # Oddly enough, the 'grading_standard_id' has to be updated via the Course API rather than Course Settings API
      # https://canvas.instructure.com/doc/api/courses.html#method.courses.update
      grading_scheme_id = @settings.default_grading_scheme_id.to_i if grading_scheme_id.nil?
      request_params = {
        'course' => {
          'grading_standard_id' => grading_scheme_id
        }
      }
      request_options = {
        :method => :put,
        :body => request_params
      }
      response = request_uncached(request_path, request_options)
      JSON.parse(response.body)
    end

    private

    def request_path
      "courses/#{@course_id}"
    end

    def request_settings
      response = request_uncached "#{request_path}/settings"
      return response ? safe_json(response.body) : nil
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', 'canvas_course_settings.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :put)
        .respond_with_file('fixtures', 'json', 'canvas_course_settings_set_grading_scheme.json')
    end

  end
end
