class MyCourseSites
  include ActiveAttr::Model

  def self.get_feed(uid)
    Rails.cache.fetch(self.cache_key(uid)) do
      course_sites = []
      if CanvasProxy.access_granted?(uid)
        canvas_proxy = CanvasProxy.new(user_id: uid)
        JSON.parse(canvas_proxy.courses.body).each do |course|
          course_sites.push({
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
        sakai_categories = sakai_proxy.get_categorized_sites(uid)[:body]["categories"] || []
        sakai_categories.each do |section|
          if current_terms.include?(section["category"])
            section["sites"].each do |site|
              course_sites.push({
                                    name: site["shortDescription"],
                                    course_code: site["title"],
                                    id: site["id"],
                                    emitter: "bSpace"
                                })
            end
          end
        end
      end
      logger.debug "MyCourseSites get_feed is #{course_sites.inspect}"
      course_sites
    end
  end

  def self.cache_key(uid)
    key = "user/#{uid}/#{self.name}"
    logger.debug "MyCourseSites cache_key will be #{key}"
    key
  end

  def self.expire(uid)
    Rails.cache.delete(self.cache_key(uid), :force => true)
  end

end
