module Canvas
  class UserCourses < Proxy
    include PagedProxy
    include Cache::UserCacheExpiry

    def courses
      self.class.fetch_from_cache(@uid) do
        all_courses = []
        params = "include[]=term&as_user_id=sis_login_id:#{@uid}&per_page=100"
        while params do
          response = request_uncached "#{request_path}?#{params}"
          break unless (response && response.status == 200 && courses = safe_json(response.body))
          all_courses.concat(courses)
          params = next_page_params(response)
        end
        all_courses
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
