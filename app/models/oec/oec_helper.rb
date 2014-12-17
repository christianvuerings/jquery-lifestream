module OecHelper

  def self.to_oec_course_hash(row)
    course_id = row[0]
    split_course_id = course_id.split('-')
    cross_listings = row[3]
    ccn = split_course_id[2].split('_')[0]
    cross_listed_name = cross_listings.present? ? cross_listings[/\((.*)\)/, 1] : nil
    {
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
      'full_name' => row[12],
      'email_address' => row[13],
      'instructor_func' => row[14],
      'blue_role' => row[15],
      'evaluate' => row[16],
      'evaluation_type' => row[17],
      'modular_course' => row[18],
      'start_date' => row[19],
      'end_date' => row[20]
    }
  end

end
