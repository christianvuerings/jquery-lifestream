class CanvasUserCoursesProxy < CanvasProxy

  def courses
    request("courses", "_courses")
  end

end