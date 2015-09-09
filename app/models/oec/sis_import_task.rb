module Oec
  class SisImportTask < Task

    def run_internal
      log :info, "Will import SIS data for term #{@term_code}"
      imports_today = find_or_create_today_subfolder('imports')
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        log :info, "Generating #{dept_code}.csv"
        worksheet = Oec::SisImportSheet.new(dept_code: dept_code)
        import_courses(worksheet, course_codes)
        export_sheet(worksheet, imports_today)
      end
    end

    def import_courses(worksheet, course_codes)
      course_codes_by_ccn = {}
      cross_listed_ccns = Set.new
      Oec::Queries.courses_for_codes(@term_code, course_codes).each do |course_row|
        if import_course(worksheet, course_row)
          course_codes_by_ccn[course_row['course_cntl_num']] ||= course_row.slice('dept_name', 'catalog_id', 'instruction_format', 'section_num')
          cross_listed_ccns.merge [course_row['cross_listed_ccns'], course_row['co_scheduled_ccns']].join(',').split(',').reject(&:blank?)
        end
      end
      additional_cross_listings = cross_listed_ccns.reject{ |ccn| course_codes_by_ccn[ccn].present? }
      Oec::Queries.courses_for_cntl_nums(@term_code, additional_cross_listings).each do |cross_listing|
        next unless should_include_cross_listing? cross_listing
        if import_course(worksheet, cross_listing)
          course_codes_by_ccn[cross_listing['course_cntl_num']] = cross_listing.slice('dept_name', 'catalog_id', 'instruction_format', 'section_num')
        end
      end
      set_cross_listed_values(worksheet, course_codes_by_ccn)
      flag_joint_faculty_gsi worksheet
      merge_supplemental_data(worksheet, course_codes)
      set_term_dates worksheet
    end

    def import_course(worksheet, course)
      course_id = course['course_id']
      row_key = "#{course_id}-#{course['ldap_uid']})"
      # Avoid duplicate rows
      unless worksheet[row_key]
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
          course['course_id_2'] = course['course_id']
          course['dept_form'] = worksheet.dept_code unless course['cross_listed_flag'].present?
          roles = Berkeley::UserRoles.roles_from_campus_row course
          course['evaluation_type'] = if roles[:student]
                                        'G'
                                      elsif roles[:faculty]
                                        'F'
                                      end
          worksheet[row_key] = Oec::Worksheet.capitalize_keys course
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

    def set_cross_listed_values(worksheet, course_codes_by_ccn)
      worksheet.each do |course_row|
        cross_listed_ccns = [course_row['CROSS_LISTED_CCNS'], course_row['CO_SCHEDULED_CCNS']].join(',').split(',').reject(&:blank?)
        cross_listed_course_codes = course_codes_by_ccn.slice(*cross_listed_ccns).values
        # A count of less than 2 means that cross-listed course codes were screened out by import_course and should not be reported.
        next if cross_listed_course_codes.count < 2
        # Official cross-listings, as opposed to room shares, will have this value already set to 'Y'.
        course_row['CROSS_LISTED_FLAG'] ||= 'RM SHARE'
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
        course_row['CROSS_LISTED_NAME'] = cross_listings_by_section_code.join(', ')
      end
    end

    def flag_joint_faculty_gsi(worksheet)
      worksheet.group_by { |row| row['COURSE_ID'] }.each do |course_id, course_rows|
        faculty_rows = course_rows.select { |row| row['EVALUATION_TYPE'] == 'F' }
        gsi_rows = course_rows.select { |row| row['EVALUATION_TYPE'] == 'G' }
        if faculty_rows.any? && gsi_rows.any?
          gsi_rows.each do |gsi_row|
            gsi_row['COURSE_ID'] = "#{gsi_row['COURSE_ID']}_GSI"
            gsi_row['COURSE_ID_2'] = "#{gsi_row['COURSE_ID_2']}_GSI"
          end
        end
      end
    end

    def merge_supplemental_data(worksheet, course_codes)
      return unless (supplemental_course_sheet = get_supplemental_worksheet Oec::Courses)

      # These columns in the 'courses' worksheet specify match conditions for rows to update.
      select_columns = %w(DEPT_NAME CATALOG_ID INSTRUCTION_FORMAT SECTION_NUM)
      # The remaining columns hold data to be merged.
      update_columns = worksheet.headers - select_columns

      supplemental_course_sheet.each do |supplemental_row|
        next unless course_codes.find { |code| code.matches_row? supplemental_row }

        rows_to_update = select_columns.inject(worksheet) do |worksheet_selection, column|
          if supplemental_row[column].blank? || worksheet_selection.none?
            worksheet_selection
          else
            worksheet_selection.select { |worksheet_row| worksheet_row[column] == supplemental_row[column] }
          end
        end
        if rows_to_update.any?
          rows_to_update.each do |row|
            row.update supplemental_row.select { |k,v| update_columns.include?(k) && v.present? }
          end
        else
          row_key = select_columns.map { |col| supplemental_row[col] }.join('-')
          worksheet[row_key] = supplemental_row
        end
      end
    end

    def set_term_dates(worksheet)
      term_slug = Berkeley::TermCodes.to_slug(*@term_code.split('-'))
      term = Berkeley::Terms.fetch.campus[term_slug]
      term_dates = {
        'START_DATE' => term.classes_start.strftime('%m-%d-%Y'),
        'END_DATE' => term.instruction_end.strftime('%m-%d-%Y')
      }
      worksheet.each { |row| row.update(term_dates) unless row['MODULAR_COURSE'].present? }
    end

  end
end
