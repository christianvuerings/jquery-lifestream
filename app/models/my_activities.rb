require 'json'

class MyActivities < MyMergedModel
  include DatedFeed

  def self.translators
    @translators ||= {}
  end

  def self.cutoff_date
    @cutoff_date ||= Time.zone.today.to_time_in_current_zone.to_datetime.advance(:days => -30).to_i
  end

  def get_feed_internal
    activities = get_canvas_activity
    append_notifications(activities)
    append_sakai_announcements(activities)
    append_regblocks(activities)
    {
        :activities => activities
    }
  end

  private

  def get_canvas_activity
    if CanvasProxy.access_granted?(@uid)
      canvas_activity_feed = CanvasUserActivityHandler.new(user_id: @uid)
      canvas_results = canvas_activity_feed.get_feed_results
    end
    canvas_results ||= []
  end

  def append_notifications(activities)
    result = []
    Notification.where(:uid => @uid).each do |notification|
      translator = (MyActivities.translators[notification.translator] ||= notification.translator.constantize.new)
      activities << translator.translate(notification)
    end
    activities
  end

  def append_sakai_announcements(activities)
    if SakaiProxy.access_granted?(@uid)
      categorized_sites = SakaiUserSitesProxy.new(user_id: @uid).get_categorized_sites
      [:classes, :groups].each do |category|
        if (sites = categorized_sites[category])
          sites.each do |site|
            announcements = SakaiSiteAnnouncementsProxy.new(site_id: site[:id]).get_announcements
            announcements.each do |sakai_ann|
              announcement = {
                  id: sakai_ann['message_id'],
                  title: sakai_ann['title'],
                  summary: sakai_ann['summary'],
                  type: 'announcement',
                  date: format_date(sakai_ann['message_date']),
                  source_url: sakai_ann['source_url'],
                  emitter: site[:emitter],
                  color_class: site[:color_class]
              }
              case category
                when :classes
                  announcement[:source] = site[:course_code]
                when :groups
                  announcement[:source] = site[:title]
              end
              activities << announcement
            end
          end
        end
      end
    end
    activities
  end

  def append_regblocks(activities)
    proxy = BearfactsRegblocksProxy.new({:user_id => @uid})
    blocks_feed = proxy.get_blocks
    doc = Nokogiri::XML blocks_feed[:body]
    doc.css("studentRegistrationBlock").each do |block|
      blocked_date = cleared_date = nil
      begin
        blocked_date = DateTime.parse(block.css("blockedDate").text)
      rescue ArgumentError # no date
      end
      begin
        cleared_date = DateTime.parse(block.css("clearedDate").text)
      rescue ArgumentError # no date
      end

      if include_in_feed?(blocked_date, cleared_date)
        if cleared_date
          title = "Registration block cleared"
          notification_type = "message"
          notification_date = cleared_date
        else
          title = "Registration block created"
          notification_type = "alert"
          notification_date = blocked_date
        end
        type = block.css("blockType").text
        reason = block.css("reason").text
        office = block.css("office").text
        summary = "Type = #{type}; Reason = #{reason}; Office = #{office}"

        Rails.logger.debug "#{self.class.name} Reg block is in feed, type = #{type}, blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"

        notification = {
            id: "",
            title: title,
            summary: summary,
            type: notification_type,
            date: format_date(notification_date),
            source: "Bearfacts",
            source_url: "https://bearfacts.berkeley.edu/bearfacts/",
            url: "https://bearfacts.berkeley.edu/bearfacts/",
            emitter: "Campus",
            color_class: "campus-item"
        }
        activities << notification
      else
        Rails.logger.debug "#{self.class.name} Reg block too old to include in feed, skipping. blocked_date = #{blocked_date}; to_i = #{blocked_date.to_i}; cleared_date = #{cleared_date}"
      end
    end
  end

  def include_in_feed?(blocked_date, cleared_date)
    if blocked_date && blocked_date.to_i >= MyActivities.cutoff_date
      return true
    end
    if cleared_date && cleared_date.to_i >= MyActivities.cutoff_date
      return true
    end
    false
  end

end
