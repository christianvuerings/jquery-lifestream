module Oec
  class CoursesImportTask < Task

    def run_internal(opts={})
      log :info, "Will import SIS data for term #{@term_code}"
      unless (term_folder = find_folder @term_code) && (imports_folder = find_folder('imports', term_folder))
        raise RuntimeError, 'Could not locate imports folder on remote drive'
      end
      unless (imports_today = find_or_create_folder(datestamp, imports_folder))
        raise RuntimeError, "Could not get imports folder dated #{datestamp} on remote drive"
      end

      course_code_filter = if opts[:dept_names]
                             {dept_name: opts[:dept_names].split}
                           elsif opts[:dept_codes]
                             {dept_code: opts[:dept_codes].split}
                           else
                             {dept_name: Oec::CourseCode.included_dept_names}
                           end

      Oec::CourseCode.by_dept_code(course_code_filter).each do |dept_code, course_codes|
        log :info, "Generating #{dept_code}.csv"
        courses = Oec::Courses.new(@tmp_path, dept_code: dept_code)
        import_courses(courses, course_codes)
        export_sheet(courses, imports_today)
      end
    end

    def import_courses(courses, course_codes)
      course_codes_by_ccn = {}
      cross_listed_ccns = Set.new
      Oec::Queries.courses_for_codes(@term_code, course_codes).each do |course_row|
        if import_course(courses, course_row)
          course_codes_by_ccn[course_row['course_cntl_num']] ||= course_row.slice('dept_name', 'catalog_id', 'instruction_format', 'section_num')
          cross_listed_ccns.merge [course_row['cross_listed_ccns'], course_row['co_scheduled_ccns']].join(',').split(',').reject(&:blank?)
        end
      end
      additional_cross_listings = cross_listed_ccns.reject{ |ccn| course_codes_by_ccn[ccn].present? }
      Oec::Queries.courses_for_cntl_nums(@term_code, additional_cross_listings).each do |cross_listing|
        next unless should_include_cross_listing? cross_listing
        if import_course(courses, cross_listing)
          course_codes_by_ccn[cross_listing['course_cntl_num']] = cross_listing.slice('dept_name', 'catalog_id', 'instruction_format', 'section_num')
        end
      end
      set_cross_listed_values(courses, course_codes_by_ccn)
    end

    def import_course(courses, course)
      course_id = course['course_id']
      row_key = "#{course_id}-#{course['ldap_uid']})"
      # Avoid duplicate rows
      unless courses[row_key]
        catalog_id = course['catalog_id']
        if course['enrollment_count'].to_i.zero?
          log :info, "Skipping course without enrollments: #{course_id}, #{course['dept_name']} #{catalog_id}"
          false
        elsif course['instructor_func'] == '3'
          log :info, "Skipping supervisor assignment of ID #{course['sis_id']} to #{course_id}, #{course['dept_name']} #{catalog_id}"
          false
        elsif %w(CLC GRP IND SUP VOL).include? course['instruction_format']
          log :info, "Skipping course with non-evaluated instruction format: #{course_id}, #{course['dept_name']} #{catalog_id}"
          false
        else
          course['dept_form'] = courses.dept_code unless course['cross_listed_flag'].present?
          courses[row_key] = Oec::Worksheet.capitalize_keys course
        end
      end
    end

    def should_include_cross_listing?(cross_listing)
      if cross_listing['cross_listed_flag'].present? || Oec::CourseCode.included?(cross_listing['dept_name'], cross_listing['catalog_id'])
        true
      else
        log :info, "Omit cross_listing #{cross_listing['course_id']} under non-participating course code #{cross_listing['dept_name']} #{cross_listing['catalog_id']}"
        false
      end
    end

    def set_cross_listed_values(courses, course_codes_by_ccn)
      courses.each do |course|
        cross_listed_ccns = [course['CROSS_LISTED_CCNS'], course['CO_SCHEDULED_CCNS']].join(',').split(',').reject(&:blank?)
        cross_listed_course_codes = course_codes_by_ccn.slice(*cross_listed_ccns).values
        # A count of less than 2 means that cross-listed course codes were screened out by import_course and should not be reported.
        next if cross_listed_course_codes.count < 2
        # Official cross-listings, as opposed to room shares, will have this value already set to 'Y'.
        course['CROSS_LISTED_FLAG'] ||= 'RM SHARE'
        last_dept_names = nil
        cross_listings_by_section_code = cross_listed_course_codes.group_by { |r| "#{r['instruction_format']} #{r['section_num']}" }.map do |section_code, rows_by_section|
          cross_listings_by_dept_name = rows_by_section.group_by { |r| r['catalog_id'] }.inject({}) do |dept_hash, (catalog_id, rows_by_catalog_id)|
            dept_names = rows_by_catalog_id.map { |r| r['dept_name'] }.uniq.join('/')
            dept_hash[dept_names] ||= []
            dept_hash[dept_names] << catalog_id
            dept_hash
          end
          course_codes = cross_listings_by_dept_name.map do |dept_names, catalog_ids|
            catalog_id_list = catalog_ids.join(', ')
            if dept_names != last_dept_names
              catalog_id_list =  "#{dept_names} #{catalog_id_list}"
              last_dept_names = dept_names
            end
            catalog_id_list
          end
          "#{course_codes.join(', ')} #{section_code}"
        end
        course['CROSS_LISTED_NAME'] = cross_listings_by_section_code.join(', ')
      end
    end

  end
end
