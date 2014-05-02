module MyAcademics
  class TeachingSakai
    include MyAcademicsModule

    def merge_sites(campus_terms)
      return unless Sakai::Proxy.access_granted?(@uid)
      sakai_sites = Sakai::SakaiMergedUserSites.new(user_id: @uid).get_feed
      sakai_sites[:courses].each do |course_site|
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
              end
            end
          end
        end
      end
    end
  end
end
