class MyClasses::Merged  < UserSpecificModel

  def get_feed_internal
    sites = []
    campus = MyClasses::Campus.new(@uid)
    campus_courses = campus.fetch
    sites.concat(campus_courses)
    MyClasses::Canvas.new(@uid).merge_sites(campus_courses, sites)
    MyClasses::SakaiClasses.new(@uid).merge_sites(campus_courses, sites)
    {
      classes: sites,
      current_term: campus.current_term.to_english
    }
  end

end
