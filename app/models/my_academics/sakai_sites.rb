module MyAcademics
  class SakaiSites
    include AcademicsModule

    def merge(data)
      if Sakai::Proxy.access_granted?(@uid) && (sakai_sites = Sakai::SakaiMergedUserSites.new(user_id: @uid).get_feed)
        sakai_sites[:courses].each do |course_site|
          if (term_yr = course_site[:term_yr]) && (term_cd = course_site[:term_cd]) &&
            (term_slug = Berkeley::TermCodes.to_slug(term_yr, term_cd))
            linked_to_campus = false
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
                      linked_to_campus = true
                      course[:class_sites] ||= []
                      site_entry = course_site_entry(course_site)
                      # Do not expose course site integrations to students, since Sakai does not expose
                      # section IDs.
                      site_entry[:sections] = linked_ccns if role_key == :teachingSemesters
                      course[:class_sites] << site_entry
                    end
                  end
                end
              end
            end
            add_other_site_membership(data, course_site) unless linked_to_campus
          end
        end
      end
      data
    end

  end
end
