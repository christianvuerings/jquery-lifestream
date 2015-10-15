module Canvas
  class UserCourses < Proxy
    include PagedProxy
    include Cache::UserCacheExpiry
    include ClassLogger

    def courses
      courses_response[:body].select do |course_site|
        if contains_expected_properties? course_site
          true
        elsif course_site['access_restricted_by_date']
          logger.info "Skipping date-restricted course site with ID #{course_site['id']} for UID #{@uid}"
          false
        else
          logger.error "Unexpected course site entry for UID #{@uid}: #{course_site}"
          false
        end
      end
    end

    def courses_response
      self.class.fetch_from_cache(@uid) do
        paged_get request_path, as_user_id: "sis_login_id:#{@uid}", include: ['term']
      end
    end

    private

    def contains_expected_properties?(course_site)
      expected_properties = %w(id term course_code)
      expected_properties.select { |prop| course_site[prop].blank? }.none?
    end

    def mock_interactions
      mock_paged_interaction 'canvas_courses'
    end

    def request_path
      'courses'
    end

  end
end
