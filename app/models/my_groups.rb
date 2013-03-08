class MyGroups < MyMergedModel

  def get_feed_internal
    response = {
        :groups => []
    }
    if SakaiProxy.access_granted?(@uid)
      sakai_proxy = SakaiProxy.new(user_id: @uid)
      sakai_categories = sakai_proxy.get_categorized_sites
      if (sites = sakai_categories['Projects'])
        sites.each do |site|
          site_hash = {
              title: site["title"] || "",
              id: site["id"],
              site_url: site["url"],
              emitter: SakaiProxy::APP_ID,
              color_class: "bspace-group"
          }
          site_hash["short_description"] = site["short_description"] unless site["short_description"].blank?
          response[:groups].push(site_hash)
        end
      end
    end
    if CanvasProxy.access_granted?(@uid)
      canvas_proxy = CanvasGroupsProxy.new(user_id: @uid)
      if (canvas_groups = canvas_proxy.groups)
        JSON.parse(canvas_groups.body).each do |group|
          response[:groups].push({
                                     title: group["name"],
                                     id: group["id"].to_s,
                                     emitter: CanvasProxy::APP_ID,
                                     color_class: "canvas-group",
                                     site_url: "#{canvas_proxy.url_root}/groups/#{group['id']}"
                                 })
        end
      end
    end
    if CalLinkProxy.access_granted?(@uid)
      membership_proxy = CalLinkMembershipsProxy.new({:user_id => @uid})
      if (cal_link_groups = membership_proxy.get_memberships)
        Rails.logger.debug "body = #{cal_link_groups[:body]}"
        if cal_link_groups[:body] && cal_link_groups[:body]["items"]
          seen_orgs = Set.new
          cal_link_groups[:body]["items"].each do |group|
            if seen_orgs.add? group["organizationId"]
              org_proxy = CalLinkOrganizationProxy.new({:org_id => group["organizationId"]})
              organization = org_proxy.get_organization[:body]
              site_url = "https://callink.berkeley.edu/"
              if organization["items"] && organization["items"][0] && organization["items"][0]["profileUrl"]
                site_url = "https://" + organization["items"][0]["profileUrl"]
              end
              response[:groups].push({
                                         title: group["organizationName"],
                                         id: group["organizationId"].to_s,
                                         emitter: CalLinkProxy::APP_ID,
                                         color_class: "callink-group",
                                         site_url: site_url
                                     })
            end
          end
        end
      end
    end
    response[:groups].sort! { |x, y| x[:title].casecmp(y[:title]) }
    logger.debug "#{self.class.name} get_feed is #{response.inspect}"
    response
  end

end
