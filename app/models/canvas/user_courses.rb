module Canvas
  class UserCourses < Proxy
    include PagedProxy
    include Cache::UserCacheExpiry

    def courses
      request_courses[:body] || []
    end

    def request_courses
      self.class.fetch_from_cache(@uid) do
        paged_get request_path, as_user_id: "sis_login_id:#{@uid}", include: ['term']
      end
    end

    private

    def mock_interactions
      mock_paged_interaction 'canvas_courses'
    end

    def request_path
      'courses'
    end

  end
end
