require 'json'

class MyActivities < MyMergedModel
  include DatedFeed, ActiveRecordHelper

  def self.translators
    @translators ||= {}
  end

  def self.cutoff_date
    @cutoff_date ||= Time.zone.today.to_time_in_current_zone.to_datetime.advance(:days => -10).to_i
  end

  def get_feed_internal
    activities = []
    append_canvas_activities(activities)
    append_notifications(activities)
    append_sakai_announcements(activities)
    append_regblocks(activities)
    {
        :activities => activities
    }
  end

  private

  def append_canvas_activities(activities)
    if CanvasProxy.access_granted?(@uid)
      canvas_activity_feed = CanvasUserActivities.new(@uid)
      canvas_results = canvas_activity_feed.get_feed
      activities.concat(canvas_results)
    end
  end

  def append_notifications(activities)
    result = []
    use_pooled_connection {
      result = Notification.where(:uid => @uid, :occurred_at => Time.at(MyActivities.cutoff_date)..Time.now) || []
    }
    result.each do |notification|
      translator = (MyActivities.translators[notification.translator] ||= notification.translator.constantize.new)
      event = translator.translate(notification)
      #basic validation before inserting into notifications array.
      if event.present? && event.kind_of?(Hash)
        activities << event
      end
    end
    activities
  end

  def append_sakai_announcements(activities)
    if SakaiProxy.access_granted?(@uid)
      categorized_sites = SakaiUserSitesProxy.new(user_id: @uid).get_categorized_sites
      [:classes, :groups].each do |category|
        if (sites = categorized_sites[category])
          sites.each do |site|
            announcements = SakaiSiteAnnouncementsProxy.new(site_id: site[:id]).get_announcements(site[:groups])
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
                  announcement[:source] = site[:name]
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
    blocks_feed = proxy.get

    #Bearfacts proxy will return nil on >= 400 errors.
    return activities if blocks_feed.nil?

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
        type = block.css("blockType").text.strip
        status = block.css("status").text.strip

        translated_codes = RegBlockCodeTranslator.new().translate_bearfacts_proxy(block.css('reasonCode').text, block.css('office').text)
        block_type = translated_codes[:type]
        block_reason = translated_codes[:reason]
        office = translated_codes[:office]
        if cleared_date
          notification_type = "message"
          notification_date = cleared_date
          title ="#{block_type} Block Cleared: #{block_reason}"
          message = "This block, placed on #{format_date(blocked_date)[:date_string]}, was cleared on #{format_date(cleared_date)[:date_string]}"
        else
          notification_type = "alert"
          notification_date = blocked_date
          message = translated_codes[:message]
          title = "#{block_type} Block Placed: #{block_reason}"
        end

        Rails.logger.debug "#{self.class.name} Reg block is in feed, type = #{type}, blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"

        notification = {
            id: '',
            title: title,
            summary: message,
            short_description: office,
            block_type: block_type,
            type: notification_type,
            date: format_date(notification_date),
            source: "BearFacts",
            source_url: "https://bearfacts.berkeley.edu/bearfacts/",
            url: "https://bearfacts.berkeley.edu/bearfacts/",
            emitter: "BearFacts",
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
