module Canvas
  class CanvasGroupsProxy < CanvasProxy

    def groups
      request("users/self/groups?as_user_id=sis_login_id:#{@uid}", "_groups")
    end

  end
end
