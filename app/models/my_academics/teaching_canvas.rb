module MyAcademics
  class TeachingCanvas
    include AcademicsModule

    def merge_sites(campus_courses)
      return unless Canvas::Proxy.access_granted?(@uid)
      if (canvas_sites = Canvas::MergedUserSites.new(@uid).get_feed)
        included_course_sites = {}
        canvas_sites[:courses].each do |course_site|
          if (merged_courses = course_site_merge(campus_courses, course_site))
            included_course_sites[course_site[:id]] = merged_courses
          end
        end
        canvas_sites[:groups].each do |group_site|
          if (linked_id = group_site[:course_id]) && (linked_classes = included_course_sites[linked_id])
            group_entry = group_site_entry(group_site, linked_classes[:source])
            linked_term = campus_courses[linked_classes[:term_idx]][:classes]
            linked_classes[:slugs].each do |slug|
              linked_class = linked_term.select {|c| c[:slug] == slug}.first
              linked_class[:class_sites] << group_entry
            end
          end
        end
      end
    end

    def course_site_merge(campus_terms, course_site)
      merged_courses = nil
      if (term_yr = course_site[:term_yr]) && (term_cd = course_site[:term_cd]) &&
        (term_slug = Berkeley::TermCodes.to_slug(term_yr, term_cd)) && (site_sections = course_site[:sections])
        if (matching_term_idx = campus_terms.index {|t| t[:slug] == term_slug})
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
              course[:class_sites] << course_site_entry(course_site).merge({sections: linked_ccns})
              merged_courses ||= {
                term_idx: matching_term_idx,
                source: course_site[:name],
                slugs: []
              }
              merged_courses[:slugs] << course[:slug]
            end
          end
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
