module OecLegacy
  class RowConverter

    attr_reader :hashed_row
    attr_reader :warnings

    def initialize(row)
      course_id = row[0]
      split_course_id = course_id.split('-')
      cross_listings = row[3]
      cross_listed_name = cross_listings.present? ? cross_listings[/\((.*)\)/, 1] : nil
      @hashed_row = {
        'term_cd' => split_course_id[1],
        'course_id' => course_id,
        'course_name' => row[1].strip,
        'cross_listed_flag' => row[2],
        'cross_listed_name' => cross_listed_name,
        'course_title_short' => cross_listings.present? ? cross_listings[/(.*?)\s\(/, 1] : nil,
        'dept_name' => row[4],
        'catalog_id' => row[5],
        'instruction_format' => row[6],
        'section_num' => row[7],
        'primary_secondary_cd' => row[8],
        # See below for column 9 containing ldap_uid
        'sis_id' =>  row[10],
        'first_name' => row[11],
        'last_name' => row[12],
        'email_address' => row[13],
        # See below for column 14 containing ldap_uid
        'blue_role' => row[15],
        'evaluate' => row[16],
        'dept_form' => row[17],
        'evaluation_type' => row[18],
        'modular_course' => row[19],
        'start_date' => row[20],
        'end_date' => row[21]
      }
      # Validate certain fields
      @warnings = []
      put_valid_i(row, 'term_yr', split_course_id[0], '2\d{3}')
      put_valid_i(row, 'course_cntl_num', split_course_id[2].split('_')[0], '\d{4,5}')
      ldap_uid = row[9]
      instructor_func = row[14]
      put_valid_i(row, 'ldap_uid', ldap_uid, '\d{1,10}') unless ldap_uid.blank?
      put_valid_i(row, 'instructor_func', instructor_func, '[1-4]') unless instructor_func.blank?
    end

    def put_valid_i(row, column_name, value, regex)
      value.strip! unless value.nil?
      matches_regex = value =~ /^#{regex}$/
      # Record value regardless of validity. Report warning, if necessary.
      @hashed_row[column_name] = matches_regex ? value.to_i : value
      unless matches_regex
        @warnings << <<-eos
          #{value} in #{column_name} column does not match #{regex}. Raw row data:
          #{row.to_s}
        eos
      end
    end

  end
end
