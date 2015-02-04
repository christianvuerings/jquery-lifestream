module MyGroups
  class Sakai
    include GroupsModule

    def fetch
      sites = []
      return sites unless ::Sakai::Proxy.access_granted?(@uid)
      sakai_sites = ::Sakai::SakaiMergedUserSites.new(user_id: @uid).get_feed
      sakai_sites[:groups].each do |group_site|
        sites << {
          emitter: group_site[:emitter],
          id: group_site[:id],
          name: group_site[:name],
          shortDescription: group_site[:short_description],
          site_url: group_site[:site_url]
        }
      end
      sites
    end

  end
end
