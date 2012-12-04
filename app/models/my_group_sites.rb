class MyGroupSites
  include ActiveAttr::Model

  def self.get_feed(uid)
    Rails.cache.fetch(self.cache_key(uid)) do
      group_sites = []
      if SakaiProxy.access_granted?
        sakai_proxy = SakaiProxy.new
        sakai_categories = sakai_proxy.get_categorized_sites(uid)[:body]["categories"] || []
        sakai_categories.each do |section|
          if %w(Other Projects).include?(section["category"])
            section["sites"].each do |site|
              next if site["url"].blank? || site["id"].blank?
              site_hash = {
                  title: site["title"] || "",
                  id: site["id"],
                  site_url: site["url"],
                  emitter: "bSpace"
                }
              site_hash["short_description"] = site["shortDescription"] unless site["shortDescription"].blank?
              group_sites.push(site_hash)
            end
          end
        end
      end
      logger.debug "#{self.name} get_feed is #{group_sites.inspect}"
      group_sites
    end
  end

  def self.cache_key(uid)
    key = "user/#{uid}/#{self.name}"
    logger.debug "#{self.name} cache_key will be #{key}"
    key
  end

  def self.expire(uid)
    Rails.cache.delete(self.cache_key(uid), :force => true)
  end

end
