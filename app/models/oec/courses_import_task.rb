module Oec
  class CoursesImportTask < Task

    def run_internal
      log :info, "Will import SIS data for term #{@term_code}"
      unless (term_folder = find_folder @term_code) && (imports_folder = find_folder('imports', term_folder))
        raise RuntimeError, 'Could not locate imports folder on remote drive'
      end
      unless (imports_today = find_or_create_folder(datestamp, imports_folder))
        raise RuntimeError, "Could not get imports folder dated #{datestamp} on remote drive"
      end
      Oec::CourseCode.included_by_dept_code.each do |dept_code, course_codes|
        log :info, "Generating #{dept_code}.csv"
        courses = Oec::Courses.new(@tmp_path, dept_code: dept_code)
        import_courses(courses, course_codes)
        export_to_folder(courses, imports_today)
      end
    end

    def import_courses(courses, course_codes)
      Oec::Queries.courses_for_codes(@term_code, course_codes).each do |course|
        # No practical way to combine these fields in SQL, so we'll do it here in Ruby.
        if course['cross_listed_name'].present?
          # get all the cross listings of this course, even if they're in departments not part of our filter.
          Oec::Queries.courses_for_cntl_nums(@term_code, course['cross_listed_name']).each do |cross_listing|
            if should_include_cross_listing? cross_listing
              import_course(courses, cross_listing)
            end
          end
        else
          import_course(courses, course)
        end
      end
    end

    def import_course(courses, course, check_secondary_cross_listings = true)
      course_id = course['course_id']
      row_key = "#{course_id}-#{course['ldap_uid']})"
      # Avoid duplicate rows
      unless courses[row_key]
        catalog_id = course['catalog_id']
        if course['enrollment_count'].to_i.zero?
          log :info, "Skipping course without enrollments: #{course_id}, #{course['dept_name']} #{catalog_id}"
        else
          course['dept_form'] = courses.dept_code unless course['cross_listed_flag'].present?
          courses[row_key] = row_for_csv course
        end
        if course['primary_secondary_cd'] == 'S' && check_secondary_cross_listings
          Oec::Queries.get_secondary_cross_listings(@term_code, [course['course_cntl_num']]).each do |cross_listed_course|
            import_course(courses, cross_listed_course, false) if should_include_cross_listing? cross_listed_course
          end
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

    def row_for_csv(row)
      transformed_row = Oec::CsvExport.capitalize_keys row
      transformed_row.delete 'COURSE_TITLE_SHORT'
      transformed_row['CROSS_LISTED_NAME'] = "#{row['course_title_short']} (#{row['cross_listed_name']})" if row['cross_listed_name'].present?
      transformed_row
    end

  end
end
