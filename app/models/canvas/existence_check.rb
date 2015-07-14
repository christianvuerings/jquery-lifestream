module Canvas
  class ExistenceCheck < Proxy

    def account_defined?(sis_account_id)
      response = request_uncached("accounts/sis_account_id:#{sis_account_id}")
      response.present?
    end

    def course_defined?(sis_course_id)
      response = request_uncached("courses/sis_course_id:#{sis_course_id}?include[]=all_courses", '_course')
      response.present?
    end

    def section_defined?(sis_section_id)
      response = request_uncached("sections/sis_section_id:#{sis_section_id}", '_section')
      response.present?
    end

    def existence_check
      true
    end

    private

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
