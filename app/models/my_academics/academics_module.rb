module MyAcademics
  module AcademicsModule

    def initialize(uid)
      @uid = uid
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

    def course_info(campus_course)
      campus_course.slice(:role, :sections, :slug).merge({
        title: campus_course[:name],
        url: class_to_url(campus_course)
      }).merge course_listing(campus_course)
    end

    def course_info_with_multiple_listings(campus_course)
      campus_course.slice(:role, :sections, :slug).merge({
        listings: [ course_listing(campus_course) ],
        title: campus_course[:name],
        url: class_to_url(campus_course)
      })
    end

    def course_listing(campus_course)
      campus_course.slice(:course_code, :dept, :dept_desc).merge({
        courseCatalog: campus_course[:course_catalog],
        course_id: campus_course[:id]
      })
    end

    def course_site_entry(course_site)
      course_site.slice(:emitter, :id, :name, :shortDescription, :site_url).merge({
        siteType: 'course',
      })
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

    def append_with_merged_crosslistings(term, course_info)
      working_course = course_info.deep_dup
      cross_listing_hash = nil
      working_course[:sections].each do |section|
        section[:courseCode] = working_course[:listings].first[:course_code]
        # Campus data's current way of indicating cross-listing relies on links
        # between the primary sections of each course.
        cross_listing_hash = section[:cross_listing_hash] if section[:cross_listing_hash].present?
      end
      if cross_listing_hash.present?
        # If the cross-listed course is already in the feed, append section and listing data.
        if (existing_cross_listed_course = term.find { |course| course[:crossListingHash] == cross_listing_hash })
          existing_cross_listed_course[:listings].concat working_course[:listings]
          concat_sections_flagging_crosslistings(working_course, existing_cross_listed_course)
          #Since courses have only one slug and URL, keep consistent by using the first alphabetically.
          if working_course[:slug] < existing_cross_listed_course[:slug]
            existing_cross_listed_course[:slug] = working_course[:slug]
            existing_cross_listed_course[:url] = working_course[:url]
          end
        else
          working_course[:crossListingHash] = cross_listing_hash
          append_with_scheduled_section_count(term, working_course)
        end
      else
        append_with_scheduled_section_count(term, working_course)
      end
    end

    def concat_sections_flagging_crosslistings(source_course, target_course)
      source_course[:sections].each do |source_section|
        if (target_section = target_course[:sections].find { |t| t[:section_label] == source_section[:section_label] })
          source_section[:scheduledWithCcn] = target_section[:ccn]
          target_section[:instructors] = target_section[:instructors] | source_section[:instructors]
          target_section[:schedules] = target_section[:schedules] | source_section[:schedules]
        end
      end
      target_course[:sections].concat source_course[:sections]
    end

    def append_with_scheduled_section_count(term, course_info)
      scheduled_section_count = 0
      scheduled_sections = Hash.new(0)
      course_info[:sections].each do |section|
        next if section[:scheduledWithCcn].present?
        scheduled_section_count += 1
        scheduled_sections[section[:instruction_format]] += 1
      end
      course_info[:scheduledSectionCount] = scheduled_section_count
      course_info[:scheduledSections] = scheduled_sections.map do |format, count|
        {
          format: decode_instruction_format(format),
          count: count
        }
      end
      # For now, resolve discrepancies between the teachingSemesters feed (which splits data
      # into listings) and the semesters feed (which doesn't) by merging the first listing
      # into the top level.
      course_info.merge! course_info[:listings].first
      term << course_info
    end

    def decode_instruction_format(format)
      case format
        when 'CLC' then 'clinic'
        when 'COL' then 'colloquium'
        when 'DEM' then 'demonstration'
        when 'DIS' then 'discussion'
        when 'FLD' then 'field study'
        when 'GRP' then 'group study'
        when 'IND' then 'independent study'
        when 'INT' then 'internship'
        when 'LAB' then 'laboratory'
        when 'LEC' then 'lecture'
        when 'REC' then 'recitation'
        when 'SEM' then 'seminar'
        when 'SES' then 'session'
        when 'STD' then 'studio'
        when 'SUP' then 'supplemental'
        when 'TUT' then 'tutorial'
        when 'VOL' then 'voluntary'
        when 'WBL' then 'web-based lecture'
        when 'WOR' then 'workshop'
        else format
      end
    end
  end
end
