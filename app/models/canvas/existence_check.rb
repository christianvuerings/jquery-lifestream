module Canvas
  class ExistenceCheck < Proxy

    def account_defined?(sis_account_id)
      resource_at_path? "accounts/sis_account_id:#{sis_account_id}"
    end

    def course_defined?(sis_course_id)
      resource_at_path? "courses/sis_course_id:#{sis_course_id}?include[]=all_courses"
    end

    def section_defined?(sis_section_id)
      resource_at_path? "sections/sis_section_id:#{sis_section_id}"
    end

    def existence_check
      true
    end

    private

    def resource_at_path?(path)
      (response = raw_request path) && response.status < 400
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/accounts/sis_account_id")
        .respond_with_file('fixtures', 'json', 'canvas_admin.json')

      on_request(uri_matching: "#{api_root}/accounts/sis_course_id")
        .respond_with_file('fixtures', 'json', 'canvas_course.json')

      on_request(uri_matching: "#{api_root}/accounts/sis_section_id")
        .respond_with_file('fixtures', 'json', 'canvas_section.json')
    end
  end
end
