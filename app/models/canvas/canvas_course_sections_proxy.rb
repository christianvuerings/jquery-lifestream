class CanvasCourseSectionsProxy < CanvasProxy
  def initialize(options = {})
    super(options)
    @course_id = options[:course_id]
  end

  def self.cache_key course_id
    "global/#{self.name}/#{course_id}"
  end

  def sections_list
    self.class.fetch_from_cache @course_id do
      request_uncached("courses/#{@course_id}/sections", "_course_sections")
    end
  end

end
