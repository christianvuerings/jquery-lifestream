module Canvas
  class CourseUsers < Proxy

    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def course_users(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      if options[:cache].present?
        self.class.fetch_from_cache(@course_id) { request_course_users }
      else
        request_course_users
      end
    end

    private

    # Interface to request all users in a course
    # See https://canvas.instructure.com/doc/api/courses.html#method.courses.users
    def request_course_users
      all_users = []
      params = "include[]=enrollments&per_page=30"
      while params do
        response = request_uncached(
          "courses/#{@course_id}/users?#{params}",
          "_course_users"
        )
        break unless (response && response.status == 200 && users_list = safe_json(response.body))
        all_users.concat(users_list)
        params = next_page_params(response)
      end
      all_users
    end

  end
end
