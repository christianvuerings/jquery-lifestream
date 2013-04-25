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
              site[:courses] = get_courses_from_provider(row['provider_id'])
              (categories[:classes] ||= []) << site
          end
        end
      end
      categories
    end
  end

  def get_courses_from_provider(provider_string)
    if !provider_string.blank?
      # Looks like "2013-B-7405+2013-B-7414+2013-B-7417+2013-B-7420+2013-B-7423+2013-B-7426"
      section_ids = provider_string.split('+')
      # If sections from multiple terms could be included in a single course site, then
      # we would use a terms-to-courses map. However, the Sakai site management UX restricts
      # course sites to a single academic term.
      term_yr = term_cd = nil
      ccns = []
      section_ids.each do |section_id|
        (term_yr, term_cd, ccn) = section_id.split('-')
        ccns << ccn
      end
      courses_data = CampusData.get_courses_from_sections(term_yr, term_cd, ccns)
      courses = courses_data.collect do |cd|
        {
            term_yr: cd['term_yr'],
            term_cd: cd['term_cd'],
            dept: cd['dept_name'],
            catid: cd['catalog_id']
        }
      end
    else
      courses = []
    end
    courses
  end

end