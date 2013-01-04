class SakaiUnreadProxy < SakaiProxy

  def get_unread_sites(uid)
    url = "#{@settings.host}/sakai-hybrid/sites?unread=true"
    do_get(uid, url)
  end

end
