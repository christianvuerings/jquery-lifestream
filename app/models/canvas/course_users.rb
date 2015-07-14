module Canvas
  class CourseUsers < Proxy
    include PagedProxy
    include SafeJsonParser

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
      @paging_callback = options[:paging_callback]
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
      params = "include[]=enrollments&per_page=100"
      while params do
        response = request_uncached "#{request_path}?#{params}"
        break unless (response && response.status == 200 && users_list = safe_json(response.body))
        all_users.concat(users_list)

        if @paging_callback.present?
          parsed_link_header = LinkHeader.parse(response['link'])
          last_link = parsed_link_header.find_link(['rel', 'last']).href
          current_link = parsed_link_header.find_link(['rel', 'current']).href
          current_page_number = /\bpage=([0-9]+)/.match(current_link)[1]
          last_page_number = /\bpage=([0-9]+)/.match(last_link)[1]
          @paging_callback.background_job_set_total_steps(last_page_number)
          @paging_callback.background_job_complete_step("Retrieving Canvas Course Users - Page #{current_page_number} of #{last_page_number}")
        end

        params = next_page_params(response)
      end
      all_users
    end

    private

    def mock_interactions
      mock_paged_interaction 'canvas_course_users'
    end

    def request_path
      "courses/#{@course_id}/users"
    end

  end
end
