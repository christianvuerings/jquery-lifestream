class MyClasses::Merged  < MyMergedModel

  def get_feed_internal
    sites = []
    campus_courses = MyClasses::Campus.new(@uid).fetch
    sites.concat(campus_courses)
    MyClasses::Canvas.new(@uid).merge_sites(campus_courses, sites)
    MyClasses::Sakai.new(@uid).merge_sites(campus_courses, sites)
    {
      classes: sites,
      current_term: Settings.sakai_proxy.current_terms.first
    }
  end

end
