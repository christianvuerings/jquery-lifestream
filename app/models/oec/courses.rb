module Oec
  class Courses < Export

    def base_file_name
      "courses"
    end

    def headers
      'COURSE_ID,COURSE_NAME,CROSS_LISTED_FLAG,CROSS_LISTED_NAME,DEPT_NAME,CATALOG_ID,INSTRUCTION_FORMAT,SECTION_NUM,PRIMARY_SECONDARY_CD,LDAP_UID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,INSTRUCTOR_FUNC,BLUE_ROLE,EVALUATE,EVALUATION_TYPE,MODULAR_COURSE,START_DATE,END_DATE'
    end

    def append_records(output)
      visited_row_list = Set.new
      Oec::Queries.get_all_courses.each do |course|
        row = record_to_csv_row(course)
        # No practical way to combine these fields in SQL, so we'll do it here in Ruby.
        if course["cross_listed_name"].present?
          # get all the cross listings of this course, even if they're in departments not part of our filter.
          cross_listings = Oec::Queries.get_all_courses(course["cross_listed_name"])
          cross_listings.each do |crosslist|
            cross_list_row = record_to_csv_row(crosslist)
            cross_list_row["CROSS_LISTED_NAME"] = "#{crosslist["course_title_short"]} (#{crosslist["cross_listed_name"]})"
            cross_list_row.delete "COURSE_TITLE_SHORT"
            append_row(output, cross_list_row, visited_row_list)
          end
          row.delete "COURSE_TITLE_SHORT"
        else
          row.delete "COURSE_TITLE_SHORT"
          append_row(output, row, visited_row_list)
        end
      end
    end

    def append_row(output, row, visited_row_list)
      # The above non-practical way to identify cross-listings requires a non-practical way to avoid duplicate rows.
      row_as_string = row.to_s
      unless visited_row_list.include?(row_as_string)
        output << row
        visited_row_list << row_as_string
      end
    end

  end
end
