class MyCourseSites
  include ActiveAttr::Model

  def self.get_feed(uid)
    Rails.cache.fetch(self.cache_key(uid)) do
      course_sites = []
      if Oauth2Data.access_granted?(uid, "canvas")
        canvas_proxy = CanvasProxy.new(user_id: uid)
        JSON.parse(canvas_proxy.courses.body).each do |course|
          course_sites.push({name: course["name"], course_code: course["course_code"], id: course["id"].to_s, emitter: "Canvas"})
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

  def expire(uid)
    Rails.cache.delete(self.class.cache_key(uid), :force => true)
  end

end
