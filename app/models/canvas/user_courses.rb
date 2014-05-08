module Canvas
  class UserCourses < Proxy

    include Cache::UserCacheExpiry

    def courses
      self.class.fetch_from_cache(@uid) do
        all_courses = []
        params = "include[]=term&as_user_id=sis_login_id:#{@uid}&per_page=100"
        while params do
          response = request_uncached("courses?#{params}", '_courses')
          break unless (response && response.status == 200 && courses = safe_json(response.body))
          all_courses.concat(courses)
          params = next_page_params(response)
        end
        all_courses
      end
    end

  end
end
