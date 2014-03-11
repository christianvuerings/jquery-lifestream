class CanvasCourseTeachersProxy < CanvasProxy

  include SafeJsonParser

  def initialize(options = {})
    super(options)
    @course_id = options[:course_id]
  end

  def self.cache_key course_id
    "global/#{self.name}/#{course_id}"
  end

  def full_teachers_list
    self.class.fetch_from_cache @course_id do
      all_teachers = []
      params = "enrollment_type=teacher&include[]=enrollments&per_page=30"
      while params do
        response = request_uncached(
            "courses/#{@course_id}/users?#{params}",
            "_course_teachers"
        )
        break unless (response && response.status == 200 && teachers_list = safe_json(response.body))
        all_teachers.concat(teachers_list)
        params = next_page_params(response)
      end
      all_teachers
    end
  end

end
