class MyGroups < MyMergedModel

  def get_feed_internal
    response = {
        :groups => []
    }
    if SakaiProxy.access_granted?
      sakai_proxy = SakaiCategorizedProxy.new
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
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasGroupsProxy.new(user_id: @uid)
      JSON.parse(canvas_proxy.groups.body).each do |group|
        response[:groups].push({
                                    title: group["name"],
                                    id: group["id"].to_s,
                                    emitter: CanvasProxy::APP_ID,
                                    color_class: "canvas-group",
                                    site_url: "#{canvas_proxy.url_root}/groups/#{group['id']}"
                                })
      end
    end
    response[:groups].sort! {|x, y| x[:title].casecmp(y[:title])}
    logger.debug "#{self.class.name} get_feed is #{response.inspect}"
    response
  end

end
