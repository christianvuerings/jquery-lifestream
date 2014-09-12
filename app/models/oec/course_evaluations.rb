module Oec
  class CourseEvaluations < Export

    def base_file_name
      "course_evaluations"
    end

    def headers
      'COURSE_ID,COURSE_NAME,CROSS_LISTED_FLAG,CROSS_LISTED_NAME,DEPT_NAME,CATALOG_ID,INSTRUCTION_FORMAT,SECTION_NUM,PRIMARY_SECONDARY_CD,LDAP_UID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,INSTRUCTOR_FUNC,BLUE_ROLE,EVALUATE,EVALUATION_TYPE,MODULAR_COURSE,START_DATE,END_DATE'
    end

    def append_records(output)
      Oec::Queries.get_all_course_evaluations.each do |evaluation|
        row = record_to_csv_row(evaluation)
        # No practical way to combine these fields in SQL, so we'll do it here in Ruby.
        if evaluation["cross_listed_name"].present?
          # get all the cross listings of this course, even if they're in departments not part of our filter.
          cross_listings = Oec::Queries.get_all_course_evaluations(evaluation["cross_listed_name"])
          cross_listings.each do |crosslist|
            cross_list_row = record_to_csv_row(crosslist)
            cross_list_row["CROSS_LISTED_NAME"] = "#{crosslist["course_title_short"]} (#{crosslist["cross_listed_name"]})"
            cross_list_row.delete "COURSE_TITLE_SHORT"
            output << cross_list_row
          end
          row.delete "COURSE_TITLE_SHORT"
        else
          row.delete "COURSE_TITLE_SHORT"
          output << row
        end
      end
    end

  end
end
