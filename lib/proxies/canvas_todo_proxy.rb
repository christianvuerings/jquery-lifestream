class CanvasTodoProxy < CanvasProxy

  def todo
    request("users/self/todo", "_todo")
  end

end
