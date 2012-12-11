class MyClasses < MyMergedModel

  def get_feed_internal
    response = {
        :classes => []
    }
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasProxy.new(user_id: @uid)
      JSON.parse(canvas_proxy.courses.body).each do |course|
        response[:classes].push({
                                    name: course["name"],
                                    course_code: course["course_code"],
                                    id: course["id"].to_s,
                                    emitter: CanvasProxy::APP_ID
                                })
      end
    end
    if SakaiProxy.access_granted?
      sakai_proxy = SakaiProxy.new
      current_terms = Settings.sakai_proxy.current_terms || []
      sakai_categories = sakai_proxy.get_categorized_sites(@uid)[:body]["categories"] || []
      sakai_categories.each do |section|
        if current_terms.include?(section["category"])
          section["sites"].each do |site|
            response[:classes].push({
                                        name: site["shortDescription"],
                                        course_code: site["title"],
                                        id: site["id"],
                                        emitter: "bSpace"
                                    })
          end
        end
      end
    end
    logger.debug "MyClasses get_feed is #{response.inspect}"
    response
  end

end
