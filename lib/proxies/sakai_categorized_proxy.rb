class SakaiCategorizedProxy < SakaiProxy

  def get_categorized_sites(uid)
    url = "#{@settings.host}/sakai-hybrid/sites?categorized=true"
    do_get(uid, url)
  end

end
