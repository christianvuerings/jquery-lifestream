class CanvasCoursesProxy < CanvasProxy

  def courses
    request("courses", "_courses")
  end

end