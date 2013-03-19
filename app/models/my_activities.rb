require 'json'

class MyActivities < MyMergedModel
  include DatedFeed

  def self.translators
    @translators ||= {}
  end

  def get_feed_internal
    activities = get_canvas_activity
    append_notifications(activities)
    append_sakai_announcements(activities)
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

end
