class MyGroups < MyMergedModel

  def get_feed_internal
    response = {
        :groups => []
    }
    if SakaiProxy.access_granted?
      sakai_proxy = SakaiProxy.new
      sakai_categories = sakai_proxy.get_categorized_sites(@uid)[:body]["categories"] || []
      filter_categories = ["Projects"]
      sakai_categories.each do |section|
        if filter_categories.include?(section["category"])
          section["sites"].each do |site|
            next if site["url"].blank? || site["id"].blank?
            site_hash = {
                title: site["title"] || "",
                id: site["id"],
                site_url: site["url"],
                emitter: "bSpace",
                color_class: "bspace-group"
            }
            site_hash["short_description"] = site["shortDescription"] unless site["shortDescription"].blank?
            response[:groups].push(site_hash)
          end
        end
      end
    end
    logger.debug "#{self.class.name} get_feed is #{response.inspect}"
    response
  end

end
