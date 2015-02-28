module MyGroups
  class Sakai
    include GroupsModule

    def fetch
      if ::Sakai::Proxy.access_granted?(@uid)
        sakai_sites = ::Sakai::SakaiMergedUserSites.new(user_id: @uid).get_feed
        sakai_sites[:groups].map { |group_site| group_site.slice(:emitter, :id, :name, :shortDescription, :site_url) }
      else
        []
      end
    end

  end
end
