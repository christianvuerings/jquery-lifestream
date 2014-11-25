module Canvas
  class CourseSections < Proxy
    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def sections_list
      self.class.fetch_from_cache @course_id do
        request_uncached("courses/#{@course_id}/sections", "_course_sections")
      end
    end

    def official_section_identifiers
      sections = sections_list.clone
      return [] unless sections && sections.status == 200
      course_sections = JSON.parse(sections.body)
      course_sections.reject! {|s| !s.include?('sis_section_id') || s['sis_section_id'].blank? }
      course_sections.collect! {|s| Canvas::Proxy.sis_section_id_to_ccn_and_term(s['sis_section_id']) }
      course_sections.compact
    end

  end
end

