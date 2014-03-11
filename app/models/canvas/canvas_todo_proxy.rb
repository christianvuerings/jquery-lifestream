module Canvas
  class CanvasTodoProxy < CanvasProxy

    def todo
      request("users/self/todo?as_user_id=sis_login_id:#{@uid}", "_todo")
    end

  end
end
