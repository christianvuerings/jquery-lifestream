# encoding: utf-8
class SakaiUserSitesProxy < SakaiProxy

  def site_url_prefix
    "#{Settings.sakai_proxy.host}/portal/site/"
  end

  def get_filtered_users_sites(sakai_user_id)
    all_sites = SakaiData.get_users_sites(sakai_user_id)
    hidden_site_ids = SakaiData.get_hidden_site_ids(sakai_user_id)
    sites = all_sites.select do |site|
      !hidden_site_ids.include?(site['site_id']) &&
          ((site['type'] != 'course') || current_terms.include?(site['term']))
    end
    sites
  end

  def get_site_to_groups_hash(sakai_user_id)
    site_to_groups = {}
    SakaiData.get_users_site_groups(sakai_user_id).each do |result|
      site_and_group = %r{/site/(.+)/group/(.+)}.match(result['realm_id'])
      if (site_id = site_and_group[1]) && (group_id = site_and_group[2])
        (site_to_groups[site_id] ||= []) << group_id
      end
    end
    site_to_groups
  end

  def get_categorized_sites
    self.class.fetch_from_cache @uid do
      categories = {}
      if (sakai_user_id = get_sakai_user_id)
        site_to_groups = get_site_to_groups_hash(sakai_user_id)
        get_filtered_users_sites(sakai_user_id).each do |row|
          site_id = row['site_id']
          site = {
              id: site_id,
              site_url: "#{site_url_prefix}#{site_id}",
              emitter: APP_ID
          }
          site[:short_description] = row['short_desc'] unless row['short_desc'].blank?
          site[:groups] = site_to_groups[site_id]
          case row['type']
            when 'project'
              site[:title] = row['title'] || ''
              site[:color_class] = 'bspace-group'
              (categories[:groups] ||= []) << site
            when 'course'
              site[:course_code] = row['title']
              site[:name] = row['short_desc']
              site[:color_class] = 'bspace-class'
              (categories[:classes] ||= []) << site
          end
        end
      end
      categories
    end
  end

end