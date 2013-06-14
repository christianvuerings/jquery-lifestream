class CanvasTodoProxy < CanvasProxy

  def todo
    request("users/self/todo?as_user_id=sis_user_id:#{@uid}", "_todo")
  end

end
