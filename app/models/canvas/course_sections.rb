module Canvas
  class CourseSections < Proxy

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def sections_list(force_write = false)
      self.class.fetch_from_cache(@course_id, force_write) { wrapped_get request_path }
    end

    def official_section_identifiers(force_write = false)
      identifiers = []
      if (course_sections = sections_list(force_write)[:body])
        course_sections.each do |s|
          next if s['sis_section_id'].blank?
          section_hash = Canvas::Terms.sis_section_id_to_ccn_and_term s['sis_section_id']
          identifiers << s.merge(section_hash) if section_hash
        end
      end
      identifiers
    end

    def create(name, sis_section_id)
      wrapped_post request_path, {
        'course_section' => {
          'name' => name,
          'sis_section_id' => sis_section_id,
          'start_at' => nil,
          'end_at' => nil,
          'restrict_enrollments_to_section_dates' => nil,
        }
      }
    end

    private

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', 'canvas_course_sections.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :post)
        .respond_with_file('fixtures', 'json', 'canvas_course_create_section.json')
    end

    def request_path
      "courses/#{@course_id}/sections"
    end
  end
end

