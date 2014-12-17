module Oec
  class Courses < Export

    def initialize(dept_name)
      super()
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
      secondary_ccn_array = []
      Oec::Queries.get_courses(nil, @dept_name).each do |course|
        row = record_to_csv_row course
        # No practical way to combine these fields in SQL, so we'll do it here in Ruby.
        if course['cross_listed_name'].present?
          # get all the cross listings of this course, even if they're in departments not part of our filter.
          cross_listings = Oec::Queries.get_courses course['cross_listed_name']
          cross_listings.each do |crosslist|
            cross_list_row = record_to_csv_row crosslist
            cross_list_row['CROSS_LISTED_NAME'] = "#{crosslist['course_title_short']} (#{crosslist['cross_listed_name']})"
            cross_list_row.delete 'COURSE_TITLE_SHORT'
            append_row(output, cross_list_row, visited_row_set, crosslist)
            append_secondary_ccn(secondary_ccn_array, course)
          end
          row.delete 'COURSE_TITLE_SHORT'
        else
          row.delete 'COURSE_TITLE_SHORT'
          append_row(output, row, visited_row_set, course)
          append_secondary_ccn(secondary_ccn_array, course)
        end
      end
      Oec::Queries.get_secondary_cross_listings(secondary_ccn_array).each do |course|
        row = record_to_csv_row course
        append_row(output, row, visited_row_set, course)
      end
    end

    def append_secondary_ccn(secondary_ccn_set, course)
      secondary_ccn_set << course['course_cntl_num'] if course['primary_secondary_cd'] == 'S'
    end

    def append_row(output, row, visited_row_list, course)
      # Avoid duplicate rows
      row_as_string = "#{course['course_id']}-#{course['ldap_uid']})"
      unless visited_row_list.include?(row_as_string)
        output << row
        visited_row_list << row_as_string
      end
    end

  end
end
