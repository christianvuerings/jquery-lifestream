class CanvasGroupsProxy < CanvasProxy

  def groups
    request("users/self/groups", "_groups")
  end

end
