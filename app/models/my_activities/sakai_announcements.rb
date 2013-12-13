class MyActivities::SakaiAnnouncements
  include DatedFeed

  def self.append!(uid, activities)
    return activities unless SakaiProxy.access_granted?(uid)

    categorized_sites = SakaiUserSitesProxy.new(user_id: uid).get_categorized_sites
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
              emitter: site[:emitter]
            }
            activities << announcement
          end
        end
      end
    end
  end

end
