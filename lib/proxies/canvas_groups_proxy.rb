class CanvasGroupsProxy < CanvasProxy

  def groups
    request("users/self/groups?as_user_id=sis_user_id:#{@uid}", "_groups")
  end

end
