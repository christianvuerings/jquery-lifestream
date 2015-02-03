module Oec
  class Courses < Export

    def initialize(dept_name, export_dir)
      super export_dir
      @dept_name = dept_name
    end

    def base_file_name
      "#{@dept_name.gsub(/\s/, '_')}_courses"
    end

    def headers
      'COURSE_ID,COURSE_NAME,CROSS_LISTED_FLAG,CROSS_LISTED_NAME,DEPT_NAME,CATALOG_ID,INSTRUCTION_FORMAT,SECTION_NUM,PRIMARY_SECONDARY_CD,LDAP_UID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,INSTRUCTOR_FUNC,BLUE_ROLE,EVALUATE,DEPT_FORM,EVALUATION_TYPE,MODULAR_COURSE,START_DATE,END_DATE'
    end

    def append_records(output)
      visited_row_set = Set.new
      departments_using_oec = Settings.oec.departments
      Oec::Queries.get_courses(nil, @dept_name).each do |course|
        row = record_to_csv_row course
        # No practical way to combine these fields in SQL, so we'll do it here in Ruby.
        if course['cross_listed_name'].present?
          # get all the cross listings of this course, even if they're in departments not part of our filter.
          cross_listings = Oec::Queries.get_courses course['cross_listed_name']
          cross_listings.each do |cross_listing|
            cross_list_row = record_to_csv_row cross_listing
            cross_listed_dept = cross_listing['dept_name']
            if cross_listing['cross_listed_flag'].to_s == '' && !departments_using_oec.include?(cross_listed_dept)
              Rails.logger.warn "#{@dept_name}.csv: Omit cross-listed #{cross_listing['course_id']} of non-participating #{cross_listed_dept} dept"
            else
              cross_list_row['CROSS_LISTED_NAME'] = "#{cross_listing['course_title_short']} (#{cross_listing['cross_listed_name']})"
              cross_list_row.delete 'COURSE_TITLE_SHORT'
              append_row(output, cross_list_row, visited_row_set, cross_listing)
            end
          end
          row.delete 'COURSE_TITLE_SHORT'
        else
          row.delete 'COURSE_TITLE_SHORT'
          append_row(output, row, visited_row_set, course)
        end
      end
    end

    def append_row(output, row, visited_row_set, course, check_secondary_cross_listings = true)
      # Avoid duplicate rows
      course_id = course['course_id']
      row_as_string = "#{course_id}-#{course['ldap_uid']})"
      unless visited_row_set.include? row_as_string
        enrollment_count = course['enrollment_count'].to_i
        catalog_id = course['catalog_id']
        if enrollment_count > 0 || catalog_id.start_with?('C')
          output << row
          visited_row_set << row_as_string
        else
          Rails.logger.warn "#{@dept_name}.csv: Skipping #{course_id}, #{course['dept_name']} #{catalog_id} because enrollment_count=#{enrollment_count}"
        end
        if course['primary_secondary_cd'] == 'S' && check_secondary_cross_listings
          Oec::Queries.get_secondary_cross_listings([course['course_cntl_num']]).each do |cross_listed_course|
            row_for_cross_listing = record_to_csv_row cross_listed_course
            append_row(output, row_for_cross_listing, visited_row_set, cross_listed_course, false)
          end
        end
      end
    end

  end
end
