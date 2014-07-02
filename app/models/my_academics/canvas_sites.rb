module MyAcademics
  class CanvasSites
    include AcademicsModule

    def merge(data)
      if Canvas::Proxy.access_granted?(@uid) && (canvas_sites = Canvas::MergedUserSites.new(@uid).get_feed)
        included_course_sites = {}
        canvas_sites[:courses].each do |course_site|
          if (merged_courses = course_site_merge(data, course_site))
            included_course_sites[course_site[:id]] = merged_courses
          end
        end
        canvas_sites[:groups].each do |group_site|
          if (linked_id = group_site[:course_id]) && (linked_classes = included_course_sites[linked_id])
            group_entry = group_site_entry(group_site, linked_classes[:source])
            linked_classes[:role_and_slugs].each do |role_and_slug|
              linked_term = data[role_and_slug[:role_key]][linked_classes[:term_idx]][:classes]
              linked_class = linked_term.select {|c| c[:slug] == role_and_slug[:slug]}.first
              linked_class[:class_sites] << group_entry
            end
          end
        end
      end
      data
    end

    # Returns the list (if any) of campus classes which include this Canvas course site.
    # This is then referred to for any Canvas group sites associated with the course site.
    def course_site_merge(data, course_site)
      merged_courses = nil
      if (term_yr = course_site[:term_yr]) && (term_cd = course_site[:term_cd]) &&
        (term_slug = Berkeley::TermCodes.to_slug(term_yr, term_cd))
        if (site_sections = course_site[:sections])
          [:semesters, :teachingSemesters].each do |role_key|
            campus_terms = data[role_key]
            if campus_terms.present? && (matching_term_idx = campus_terms.index {|t| t[:slug] == term_slug})
              # Compare CCNs as parsed integers to avoid mismatches on prefixed zeroes.
              site_ccns = site_sections.collect {|s| s[:ccn].to_i}
              campus_courses = campus_terms[matching_term_idx][:classes]
              campus_courses.each do |course|
                linked_ccns = []
                course[:sections].each do |s|
                  linked_ccns << {ccn: s[:ccn]} if site_ccns.include?(s[:ccn].to_i)
                end
                if linked_ccns.present?
                  course[:class_sites] ||= []
                  site_entry = course_site_entry(course_site)
                  # Do not expose course site integrations to students, since Canvas does not expose
                  # section IDs.
                  site_entry[:sections] = linked_ccns if role_key == :teachingSemesters
                  course[:class_sites] << site_entry
                  merged_courses ||= {
                    term_idx: matching_term_idx,
                    source: course_site[:name],
                    role_and_slugs: []
                  }
                  merged_courses[:role_and_slugs] << {role_key: role_key, slug: course[:slug]}
                end
              end
            end
          end
        end
        if merged_courses.blank?
          # This course site has a legitimate academic term but the current user is not officially
          # connected to a linked class section.
          add_other_site_membership(data, course_site)
        end
      end
      merged_courses
    end

    def group_site_entry(group_site, source)
      {
        emitter: group_site[:emitter],
        id: group_site[:id],
        name: group_site[:name],
        siteType: 'group',
        site_url: group_site[:site_url],
        source: source
      }
    end

  end
end
