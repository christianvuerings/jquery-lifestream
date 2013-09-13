class MyGroups < MyMergedModel

  def get_feed_internal
    response = {
        :groups => []
    }

    response[:groups].concat(process_sakai_sites) if SakaiUserSitesProxy.access_granted?(@uid)
    response[:groups].concat(process_canvas_sites) if CanvasProxy.access_granted?(@uid)
    response[:groups].concat(process_callink_sites) if CalLinkProxy.access_granted?(@uid)
    response[:groups].sort! { |x, y| x[:name].casecmp(y[:name]) }
    Rails.logger.debug "#{self.class.name} get_feed is #{response.inspect}"
    response
  end

  private

  def process_sakai_sites
    sakai_proxy = SakaiUserSitesProxy.new({:user_id => @uid})
    sakai_proxy.get_categorized_sites[:groups] || []
  end

  def process_canvas_sites
    canvas_proxy = CanvasUserSites.new(@uid)
    canvas_proxy.get_feed[:groups] || []
  end

  def process_callink_sites
    response = []
    membership_proxy = CalLinkMembershipsProxy.new({:user_id => @uid})
    cal_link_groups = membership_proxy.get_memberships
    return response unless cal_link_groups && cal_link_groups[:status_code] == 200

    Rails.logger.debug "#{self.class.name}::process_callink_sites: body = #{cal_link_groups[:body]}"
    if cal_link_groups[:body] && cal_link_groups[:body]["items"]
      seen_orgs = Set.new
      cal_link_groups[:body]["items"].each do |group|
        if seen_orgs.add? group["organizationId"]
          org = CalLinkOrganizationProxy.new({:org_id => group["organizationId"]}).get_organization
          next unless org && org[:status_code] == 200
          next unless filter_callink_organization!(org).present?
          organization = org[:body]
          site_url = "https://callink.berkeley.edu/"
          if organization["items"] && organization["items"][0] && organization["items"][0]["profileUrl"]
            site_url = "https://" + organization["items"][0]["profileUrl"]
          end
          response.push({
            name: group["organizationName"],
            id: group["organizationId"].to_s,
            emitter: CalLinkProxy::APP_ID,
            color_class: "callink-group",
            site_url: site_url
          })
        end
      end
    end
    response
  end

  private
  def filter_callink_organization!(org)
    return [] unless org[:body] && org[:body]["items"].present?
    org[:body]["items"].reject! do |item|
      (self.class.type_name_blacklist.include?(item["typeName"].downcase) ||
        self.class.status_blacklist.include?(item["status"].downcase))
    end
    return [] if org[:body]["items"].blank?
    org
  end

  def self.type_name_blacklist
    [
      "admin",
      "asuc government office",
      "asuc government program",
      "campus departments",
      "default",
      "ga government office",
      "ga government program",
      "hidden",
      "new organizations",
    ]
  end

  def self.status_blacklist
    %w(frozen inactive locked)
  end
end
