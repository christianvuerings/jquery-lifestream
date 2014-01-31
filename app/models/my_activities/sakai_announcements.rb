class MyActivities::SakaiAnnouncements
  include DatedFeed

  def self.append!(uid, sites, activities)
    return activities unless SakaiProxy.access_granted?(uid)
    sakai_sites = sites.select {|s| s[:emitter] == SakaiProxy::APP_ID}
    sakai_sites.each do |site|
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
          emitter: site[:emitter]
        }
        activities << announcement
      end
    end
  end

end
