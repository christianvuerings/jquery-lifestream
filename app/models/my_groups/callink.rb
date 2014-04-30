class MyGroups::Callink
  include MyGroups::GroupsModule, ClassLogger

  def fetch
    response = []
    return response unless @uid.present?
    membership_proxy = CalLink::Memberships.new({:user_id => @uid})
    cal_link_groups = membership_proxy.get_memberships
    return response unless cal_link_groups && cal_link_groups[:statusCode] == 200

    logger.debug "fetch: body = #{cal_link_groups[:body]}"
    if cal_link_groups[:body] && cal_link_groups[:body]["items"]
      seen_orgs = Set.new
      cal_link_groups[:body]["items"].each do |group|
        if seen_orgs.add? group["organizationId"]
          org = CalLink::Organization.new({:org_id => group["organizationId"]}).get_organization
          next unless org && org[:statusCode] == 200
          next unless filter_callink_organization!(org).present?
          organization = org[:body]
          site_url = "https://callink.berkeley.edu/"
          if organization["items"] && organization["items"][0] && organization["items"][0]["profileUrl"]
            site_url = "https://" + organization["items"][0]["profileUrl"]
          end
          response.push({
            name: group["organizationName"],
            id: group["organizationId"].to_s,
            emitter: CalLink::Proxy::APP_ID,
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
      (type_name_blacklist.include?(item["typeName"].downcase) ||
        status_blacklist.include?(item["status"].downcase))
    end
    return [] if org[:body]["items"].blank?
    org
  end

  def type_name_blacklist
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

  def status_blacklist
    %w(frozen inactive locked)
  end

end
