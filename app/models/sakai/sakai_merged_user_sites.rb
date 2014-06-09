module Sakai
  class SakaiMergedUserSites < Proxy
    include ClassLogger
    include Cache::UserCacheExpiry

    def get_feed
      self.class.fetch_from_cache @uid do
        get_feed_internal
      end
    end

    def get_feed_internal
      courses = []
      groups = []
      if (sakai_user_id = Sakai::SakaiData.get_sakai_user_id(@uid))
        url_root = "#{Settings.sakai_proxy.host}/portal/site"
        site_to_groups = get_site_to_groups_hash(sakai_user_id)
        get_filtered_users_sites(sakai_user_id).each do |row|
          site_id = row['site_id']
          site = {
            emitter: APP_ID,
            groups: site_to_groups[site_id],
            id: site_id,
            name: row['title'] || '',
            short_description: row['short_desc'],
            siteType: row['type'],
            site_url: "#{url_root}/#{site_id}",
          }
          if row['type'] == 'course' && (term_name = row['term']) && (term = Berkeley::TermCodes.from_english(term_name))
            site[:term_name] = term_name
            site[:term_yr] = term[:term_yr]
            site[:term_cd] = term[:term_cd]
            site[:sections] = get_sections_from_provider(row['provider_id'])
            courses << site
          else
            groups << site
          end
        end
      end
      {
        courses: courses,
        groups: groups
      }
    end

    def get_filtered_users_sites(sakai_user_id)
      all_sites = Sakai::SakaiData.get_users_sites(sakai_user_id)
      hidden_site_ids = Sakai::SakaiData.get_hidden_site_ids(sakai_user_id)
      all_sites.select { |site| !hidden_site_ids.include?(site['site_id']) }
    end

    def get_site_to_groups_hash(sakai_user_id)
      site_to_groups = {}
      Sakai::SakaiData.get_users_site_groups(sakai_user_id).each do |result|
        site_and_group = %r{/site/(.+)/group/(.+)}.match(result['realm_id'])
        if (site_id = site_and_group[1]) && (group_id = site_and_group[2])
          (site_to_groups[site_id] ||= []) << group_id
        end
      end
      site_to_groups
    end

    def get_sections_from_provider(provider_string)
      sections = []
      if provider_string.present?
        # Looks like "2013-B-7405+2013-B-7414+2013-B-7417+2013-B-7420+2013-B-7423+2013-B-7426"
        section_ids = provider_string.split('+')
        # If sections from multiple terms could be included in a single course site, then
        # we would use a terms-to-courses map. However, the Sakai site management UX restricts
        # course sites to a single academic term.
        section_ids.each do |section_id|
          (term_yr, term_cd, ccn) = section_id.split('-')
          sections << {ccn: ccn} if ccn.present?
        end
      end
      sections
    end

  end
end
