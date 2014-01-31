class MyGroups::Sakai
  include MyGroups::GroupsModule

  def fetch
    sites = []
    return sites unless SakaiProxy.access_granted?(@uid)
    sakai_sites = SakaiMergedUserSites.new(user_id: @uid).get_feed
    sakai_sites[:groups].each do |group_site|
      sites << {
        emitter: group_site[:emitter],
        id: group_site[:id],
        name: group_site[:name],
        short_description: group_site[:short_description],
        site_url: group_site[:site_url]
      }
    end
    sites
  end

end
