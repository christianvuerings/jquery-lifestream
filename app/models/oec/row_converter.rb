module Oec
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
        'first_name' => row[10],
        'last_name' => row[11],
        'email_address' => row[12],
        'blue_role' => row[14],
        'evaluate' => row[15],
        'dept_form' => row[16],
        'evaluation_type' => row[17],
        'modular_course' => row[18],
        'start_date' => row[19],
        'end_date' => row[20]
      }
      # Validate certain fields
      @warnings = []
      put_valid_i(row, 'term_yr', split_course_id[0], '2\d{3}')
      put_valid_i(row, 'course_cntl_num', split_course_id[2].split('_')[0], '[1-9]\d{3,4}')
      put_valid_i(row, 'ldap_uid', row[9], '\d{3,10}')
      put_valid_i(row, 'instructor_func', row[13], '[1-4]')
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
