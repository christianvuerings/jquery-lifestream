module CanvasLti
  class OfficialCourse
    extend Cache::Cacheable

    def initialize(options = {})
      raise RuntimeError, 'canvas_course_id required' unless options.include?(:canvas_course_id)
      @canvas_course_id = options[:canvas_course_id]
    end

    # Provides official section identifiers for sections in Canvas course
    def official_section_identifiers
      @official_section_ids ||= Canvas::CourseSections.new(:course_id => @canvas_course_id).official_section_identifiers
    end

    # Returns array of terms associated with Canvas course site
    def section_terms
      official_section_identifiers.collect {|sect| sect.slice(:term_yr, :term_cd)}.uniq
    end

    # Returns true if course site contains official sections
    def is_official_course?(options = {})
      default_options = {:cache => true}
      options.reverse_merge!(default_options)

      get_official_course_status = Proc.new {
        (official_section_identifiers.count > 0) ? true : false
      }

      if options[:cache].present?
        self.class.fetch_from_cache("is-official-#{@canvas_course_id}") { get_official_course_status.call }
      else
        get_official_course_status.call
      end
    end

  end
end
