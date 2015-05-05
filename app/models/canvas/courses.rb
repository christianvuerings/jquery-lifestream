module Canvas
  class Courses < Proxy

    def official_courses
      self.class.fetch_from_cache(@uid) do
        account_id = Settings.canvas_proxy.official_courses_account_id
        response = request_uncached("accounts/#{account_id}/courses", '_all_official_course_sites', {:method => :get})
        response ? safe_json(response.body) : nil
      end
    end

  end
end
