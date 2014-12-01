module MyAcademics
  module AcademicsModule

    def initialize(uid)
      @uid = uid
    end

    def to_text(element)
      if element.blank?
        return ""
      else
        return element.text.strip
      end
    end

    def to_array(element)
      if element.blank?
        return ""
      else
        return element.to_a.map{ |a| a.text.strip }
      end
    end

    def to_time(element)
      str = to_text(element)
      num = str.gsub(/^0/, "")
      formatted = num.insert(num.length - 2, ":")
      formatted
    end

    def make_slug(text)
      if text.blank?
        ""
      else
        text.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-')
      end
    end

    # Link campus course data to the corresponding Academics class info page.
    # This URL is internally routed by JavaScript code rather than Rails.
    def class_to_url(campus_course)
      teaching_str = (campus_course[:role] == 'Instructor') ? 'teaching-' : ''
      "/academics/#{teaching_str}semester/#{Berkeley::TermCodes.to_slug(campus_course[:term_yr], campus_course[:term_cd])}/class/#{campus_course[:slug]}"
    end

    def semester_info(term_yr, term_cd)
      slug = Berkeley::TermCodes.to_slug(term_yr, term_cd)
      {
        name: Berkeley::TermCodes.to_english(term_yr, term_cd),
        slug: slug,
        termCode: term_cd,
        termYear: term_yr,
        timeBucket: time_bucket(term_yr, term_cd),
        gradingInProgress: (terms.grading_in_progress && (slug == terms.grading_in_progress.slug)),
        classes: []
      }
    end

    def class_info(campus_course)
      {
        course_code: campus_course[:course_code],
        dept: campus_course[:dept],
        courseCatalog: campus_course[:course_catalog],
        dept_desc: campus_course[:dept_desc],
        slug: campus_course[:slug],
        title: campus_course[:name],
        sections: campus_course[:sections],
        course_id: campus_course[:id],
        url: class_to_url(campus_course)
      }
    end

    def course_site_entry(course_site)
      {
        emitter: course_site[:emitter],
        id: course_site[:id],
        name: course_site[:name],
        shortDescription: course_site[:shortDescription],
        siteType: 'course',
        site_url: course_site[:site_url]
      }
    end

    def current_term
      @current_term ||= terms.current
    end

    def terms
      @terms ||= Berkeley::Terms.fetch
    end

    def time_bucket(term_yr, term_cd)
      term_yr = term_yr.to_i
      if term_yr < current_term.year || (term_yr == current_term.year && term_cd < current_term.code)
        bucket = 'past'
      elsif term_yr > current_term.year || (term_yr == current_term.year && term_cd > current_term.code)
        bucket = 'future'
      else
        bucket = 'current'
      end
      bucket
    end

    def add_other_site_membership(feed, course_site)
      feed[:otherSiteMemberships] ||= []
      term_slug = Berkeley::TermCodes.to_slug(course_site[:term_yr], course_site[:term_cd])
      other_site_terms = feed[:otherSiteMemberships]
      unless (idx = other_site_terms.index {|t| t[:slug] == term_slug})
        other_site_terms << {
          name: Berkeley::TermCodes.to_english(course_site[:term_yr], course_site[:term_cd]),
          slug: term_slug,
          termCode: course_site[:term_cd],
          termYear: course_site[:term_yr],
          sites: []
        }
        idx = other_site_terms.length - 1
      end
      other_sites = other_site_terms[idx][:sites]
      other_sites << course_site_entry(course_site)
    end

  end
end
