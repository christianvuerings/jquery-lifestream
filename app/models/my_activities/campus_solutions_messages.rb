module MyActivities
  class CampusSolutionsMessages
    include ClassLogger, DatedFeed, HtmlSanitizer, SafeJsonParser

    def self.append!(uid, activities)
      messages = get_feed uid
      logger.debug "Raw Messages feed = #{messages}"
      activities.concat messages
    end

    def self.get_feed(uid)
      CampusSolutions::PendingMessages.new(user_id: uid).get[:feed]
      []
    end

  end
end
