class CanvasUserCoursesProxy < CanvasProxy

  def courses
    request("courses?as_user_id=sis_user_id:#{@uid}", "_courses")
  end

end