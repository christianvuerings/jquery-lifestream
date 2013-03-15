class MyClasses < MyMergedModel

  def get_feed_internal
    response = {
        :classes => []
    }
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasCoursesProxy.new(user_id: @uid)
      if (canvas_courses = canvas_proxy.courses)
        JSON.parse(canvas_courses.body).each do |course|
          response[:classes].push({
                                      name: course["name"],
                                      course_code: course["course_code"],
                                      id: course["id"].to_s,
                                      emitter: CanvasProxy::APP_ID,
                                      color_class: "canvas-class",
                                      site_url: "#{canvas_proxy.url_root}/courses/#{course['id']}"
                                  })
        end
      end
    end
    if SakaiUserSitesProxy.access_granted?(@uid)
      sakai_proxy = SakaiUserSitesProxy.new({:user_id => @uid})
      if (sakai_classes = sakai_proxy.get_categorized_sites[:classes])
        response[:classes].concat(sakai_classes)
      end
    end
    logger.debug "MyClasses get_feed is #{response.inspect}"
    response
  end

end
