module Canvas
  class CourseSections < Proxy
    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def sections_list(force_write = false)
      self.class.fetch_from_cache @course_id, force_write do
        request_uncached("courses/#{@course_id}/sections", "_course_sections")
      end
    end

    def official_section_identifiers
      sections = sections_list.clone
      return [] unless sections && sections.status == 200
      course_sections = JSON.parse(sections.body)
      course_sections.reject! {|s| !s.include?('sis_section_id') || s['sis_section_id'].blank? }
      course_sections.collect! do |s|
        section_hash = Canvas::Proxy.sis_section_id_to_ccn_and_term(s['sis_section_id'])
        s.merge(section_hash) if section_hash
      end
      course_sections.compact
    end

    def create(name, sis_section_id)
      request_params = {
        'course_section' => {
          'name' => name,
          'sis_section_id' => sis_section_id,
          'start_at' => nil,
          'end_at' => nil,
          'restrict_enrollments_to_section_dates' => nil,
        }
      }
      request_options = {
        :method => :post,
        :body => request_params,
      }
      response = request_uncached("courses/#{@course_id}/sections", "_course_create_section", request_options)
      JSON.parse(response.body)
    end

  end
end

