class MyClasses < MyMergedModel

  def get_feed_internal
    response = {
        :classes => [],
        :current_term => Settings.sakai_proxy.current_terms.first
    }
    if CampusUserCoursesProxy.access_granted?(@uid)
      response[:classes].concat(process_campus_courses)
      response[:classes].concat(process_canvas_courses) if CanvasProxy.access_granted?(@uid)
      response[:classes].concat(process_sakai_sites) if SakaiUserSitesProxy.access_granted?(@uid)
    end
    Rails.logger.debug "MyClasses get_feed is #{response.inspect}"
    response
  end

  private

  def process_campus_courses
    campus_courses = CampusUserCoursesProxy.new({:user_id => @uid}).get_campus_courses
    campus_courses.each do |course|
      # Point to My Academics class page
      course[:site_url] = MyAcademics::AcademicsModule.class_to_url(
          course[:term_cd],
          course[:term_yr],
          course[:dept],
          course[:catid],
          course[:role]
      )
    end
    campus_courses
  end

  def process_sakai_sites
    sakai_proxy = SakaiUserSitesProxy.new({:user_id => @uid})
    sakai_proxy.get_categorized_sites[:classes] || []
  end

  def process_canvas_courses
    canvas_proxy = CanvasUserSites.new(@uid)
    canvas_proxy.get_feed[:classes] || []
  end
end
