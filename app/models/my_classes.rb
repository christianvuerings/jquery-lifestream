class MyClasses < MyMergedModel

  def get_feed_internal
    response = {
        :classes => []
    }
    response[:classes].concat(process_canvas_courses) if CanvasProxy.access_granted?(@uid)
    response[:classes].concat(process_sakai_sites) if SakaiUserSitesProxy.access_granted?(@uid)
    if CampusUserCoursesProxy.access_granted?(@uid)
      response[:classes].concat(CampusUserCoursesProxy.new({:user_id => @uid}).get_campus_courses)
    end
    logger.debug "MyClasses get_feed is #{response.inspect}"
    response
  end

  private

  def process_sakai_sites
    sakai_proxy = SakaiUserSitesProxy.new({:user_id => @uid})
    sakai_proxy.get_categorized_sites[:classes] || []
  end

  def process_canvas_courses
    response = []
    canvas_proxy = CanvasUserCoursesProxy.new(user_id: @uid)
    canvas_courses = canvas_proxy.courses
    return response unless (canvas_courses && canvas_courses.status == 200)
    begin
      JSON.parse(canvas_courses.body).each do |course|
        response.push(
          {
            name: course["name"],
            course_code: course["course_code"],
            id: course["id"].to_s,
            emitter: CanvasProxy::APP_ID,
            color_class: "canvas-class",
            site_url: "#{canvas_proxy.url_root}/courses/#{course['id']}"
          })
      end
    rescue JSON::ParserError => e
      Rails.logger.warn "#{self.class.name}: Problems parsing JSON feed: #{canvas_courses.body} - #{e}"
      return []
    end
    response
  end
end
