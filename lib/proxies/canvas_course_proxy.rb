class CanvasCourseProxy < CanvasProxy
  def initialize(options = {})
    super(options)
    @course_id = options[:course_id]
  end

  def self.cache_key course_id
    "global/#{self.name}/#{course_id}"
  end

  def course
    self.class.fetch_from_cache @course_id do
      request_uncached("courses/sis_course_id:#{@course_id}", "_course")
    end
  end

end
