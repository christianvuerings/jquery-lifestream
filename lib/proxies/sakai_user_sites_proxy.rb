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

  # Because this data structure is used by multiple top-level feeds, it's essential
  # that it be cached efficiently.
  def get_categorized_sites
    self.class.fetch_from_cache @uid do
      categories = {classes: [], groups: []}
      if (sakai_user_id = get_sakai_user_id)
        campus_user_courses = CampusUserCoursesProxy.new(user_id: @uid).get_campus_courses
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
          site[:site_type] = row['type']
          case row['type']
            when 'project'
              site[:name] = row['title'] || ''
              categories[:groups] << site
            when 'course'
              linked_enrollments = get_courses_from_provider(campus_user_courses, row['provider_id']) || []
              site[:courses] = linked_enrollments
              site[:name] = row['title']
              categories[:classes] << site
          end
        end
      end
      categories
    end
  end

  def get_courses_from_provider(campus_user_courses, provider_string)
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
      linked_courses = Set.new
      campus_user_courses.each do |course|
        if course[:term_yr] == term_yr &&
            course[:term_cd] == term_cd &&
            (course[:role] == 'Student' || course[:role] == 'Instructor') &&
            course[:sections].index { |sect| ccns.include?(sect[:ccn])}
          linked_courses.add(course[:id])
        end
      end
      # TODO Support more ad-hoc maintenance of secondary section memberships, by connecting
      # sites for sections in which the student is not officially enrolled.
      if !linked_courses.empty?
        linked_courses.to_a.collect! { |id| {id: id} }
      else
        nil
      end
    else
      nil
    end
  end

end
