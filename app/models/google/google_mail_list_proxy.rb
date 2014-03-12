class GoogleMailListProxy < GoogleProxy

  def mail_unread
    simple_request({ http_method: :get, uri: Settings.google_proxy.atom_mail_feed_url, authenticated: true}, "_mail")
  end

end
