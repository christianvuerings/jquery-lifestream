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
                  source: site[:name],
                  emitter: site[:emitter],
                  color_class: site[:color_class]
              }
              activities << announcement
            end
          end
        end
      end
    end
    activities
  end

  def process_block!(block)
    blocked_date = block.try(:[], :blocked_date).try(:[], :epoch)
    cleared_date = block.try(:[], :cleared_date).try(:[], :epoch)
    if include_in_feed?(blocked_date, cleared_date)
      block.merge!(
        {
          id: '',
          source: block[:short_description] || '',
          source_url: "https://bearfacts.berkeley.edu/bearfacts/",
          url: "https://bearfacts.berkeley.edu/bearfacts/",
          emitter: "BearFacts",
          color_class: "campus-item"
        })
      if cleared_date
        process_cleared_block!(block)
      else
        process_active_block!(block)
      end

      unless (block[:block_type] == 'Academic' && block[:reason] == 'Academic')
        block[:title] += ": #{block[:reason]}"
      end

      Rails.logger.debug "#{self.class.name} Reg block is in feed, type = #{block[:block_type]}," \
        "blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"
      block
    else
      Rails.logger.debug "#{self.class.name} Reg block too old to include in feed, skipping. " \
        "blocked_date = #{blocked_date}; cleared_date = #{cleared_date}"
      nil
    end
  end

  def process_cleared_block!(block)
    block.merge!(
      {
        type: "message",
        date: block[:cleared_date],
        title: "#{block[:block_type]} Block Cleared",
        summary: "This block, placed on #{block[:blocked_date][:date_string]}, "\
          "was cleared on #{block[:cleared_date][:date_string]}."
      })
  end

  def process_active_block!(block)
    block.merge!(
      {
        type: "alert",
        date: block[:blocked_date],
        title: "#{block[:block_type]} Block Placed",
        summary: block[:message],
      }
    )
  end

  def append_regblocks(activities)
    blocks_feed = MyRegBlocks.new(@uid, @original_uid).get_feed
    if blocks_feed.empty? || blocks_feed[:available] == false
      return activities
    end

    %w(active_blocks inactive_blocks).each do |block_category|
      blocks_feed[block_category.to_sym].each do |block|
        notification = process_block!(block)
        activities << notification if notification.present?
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
