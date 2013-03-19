# encoding: utf-8
class SakaiUserSitesProxy < SakaiProxy

  def site_url_prefix
    "#{Settings.sakai_proxy.host}/portal/site/"
  end

  def get_filtered_users_sites
    if (sakai_user_id = get_sakai_user_id)
      all_sites = SakaiData.get_users_sites(sakai_user_id)
      hidden_site_ids = SakaiData.get_hidden_site_ids(sakai_user_id)
      sites = all_sites.select do |site|
        !hidden_site_ids.include?(site['site_id']) &&
            ((site['type'] != 'course') || current_terms.include?(site['term']))
      end
      sites
    else
      []
    end
  end

  def get_categorized_sites
    self.class.fetch_from_cache @uid do
      categories = {}
      get_filtered_users_sites.each do |row|
        site_id = row['site_id']
        site = {
            id: site_id,
            site_url: "#{site_url_prefix}#{site_id}",
            emitter: APP_ID
        }
        site[:short_description] = row['short_desc'] unless row['short_desc'].blank?
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
      categories
    end
  end

end