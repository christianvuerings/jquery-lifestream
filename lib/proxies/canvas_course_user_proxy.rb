class CanvasCourseUserProxy < CanvasProxy

  ADMIN_ROLES = ["TeacherEnrollment","TaEnrollment","DesignerEnrollment"]

  def initialize(options = {})
    super(options)
    raise ArgumentError, "User ID option required" unless options.has_key?(:user_id)
    raise ArgumentError, "User ID option must be a Fixnum" if options[:user_id].class != Fixnum
    raise ArgumentError, "Course ID option required" unless options.has_key?(:course_id)
    raise ArgumentError, "Course ID option must be a Fixnum" if options[:course_id].class != Fixnum
    @user_id = options[:user_id]
    @course_id = options[:course_id]
  end

  def course_user(options = {})
    default_options = {:cache => true}
    options.reverse_merge!(default_options)

    if options[:cache].present?
      self.class.fetch_from_cache("#{@course_id}/#{@user_id}") { request_course_user }
    else
      request_course_user
    end
  end

  def self.is_course_admin?(canvas_course_user)
    return false if canvas_course_user.blank?
    canvas_course_user['enrollments'].each do |enrollment|
      return true if ADMIN_ROLES.include?(enrollment['role'])
    end
    false
  end

  private

  # Interface to request a single users in a course
  # See https://canvas.instructure.com/doc/api/courses.html#method.courses.user
  def request_course_user
    response = request_uncached(
      "courses/#{@course_id}/users/#{@user_id}?include[]=enrollments",
      "_course_user"
    )
    return response ? JSON.parse(response.body) : nil
  end

end
