module Canvas
  class CourseUsers < Proxy
    include PagedProxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
      @paging_callback = options[:paging_callback]
    end

    def course_users(options = {})
      optional_cache(options, key: "#{@course_id}/#{@user_id}", default: true) do
        paged_get(request_path, include: ['enrollments']) do |response|
          if @paging_callback.present?
            parsed_link_header = LinkHeader.parse(response['link'])
            last_link = parsed_link_header.find_link(['rel', 'last']).href
            current_link = parsed_link_header.find_link(['rel', 'current']).href
            current_page_number = /\bpage=([0-9]+)/.match(current_link)[1]
            last_page_number = /\bpage=([0-9]+)/.match(last_link)[1]
            @paging_callback.background_job_set_total_steps(last_page_number)
            @paging_callback.background_job_complete_step("Retrieving Canvas Course Users - Page #{current_page_number} of #{last_page_number}")
          end
        end
      end
    end

    private

    def mock_interactions
      mock_paged_interaction 'canvas_course_users'
    end

  # Interface to request all users in a course
  # See https://canvas.instructure.com/doc/api/courses.html#method.courses.users
    def request_path
      "courses/#{@course_id}/users"
    end

  end
end
