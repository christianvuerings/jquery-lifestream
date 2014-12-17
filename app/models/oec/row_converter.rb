module Oec
  class RowConverter

    attr_reader :hashed_row

    def initialize(row)
      course_id = row[0]
      split_course_id = course_id.split('-')
      cross_listings = row[3]
      ccn = split_course_id[2].split('_')[0]
      cross_listed_name = cross_listings.present? ? cross_listings[/\((.*)\)/, 1] : nil
      @hashed_row = {
        'term_yr' => split_course_id[0],
        'term_cd' => split_course_id[1],
        'course_cntl_num' => ccn,
        'course_id' => course_id,
        'course_name' => row[1],
        'cross_listed_flag' => row[2],
        'cross_listed_name' => cross_listed_name,
        'course_title_short' => cross_listings.present? ? cross_listings[/(.*?)\s\(/, 1] : nil,
        'dept_name' => row[4],
        'catalog_id' => row[5],
        'instruction_format' => row[6],
        'section_num' => row[7],
        'primary_secondary_cd' => row[8],
        'ldap_uid' => row[9],
        'first_name' => row[10],
        'last_name' => row[11],
        'email_address' => row[12],
        'instructor_func' => row[13],
        'blue_role' => row[14],
        'evaluate' => row[15],
        'evaluation_type' => row[16],
        'modular_course' => row[17],
        'start_date' => row[18],
        'end_date' => row[19]
      }
    end

  end
end
