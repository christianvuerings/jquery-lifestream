module Oec
  class CoursesDiff < Export

    COLUMN_LDAP_UID = 'ldap_uid'
    COLUMN_COURSE_ID = 'course_id'

    # true if course data provided by dept representative differs from campus db data
    attr_reader :was_difference_found

    def initialize(dept_name, campus_data, data_from_dept, export_dir)
      super export_dir
      @was_difference_found = false
      @instructor_columns = %w(first_name last_name email_address instructor_func)
      @columns_to_compare = %w(course_name).concat @instructor_columns
      @dept_name = dept_name
      @data_from_dept = data_from_dept
      @campus_data_hash = {}
      campus_data.each do |campus_record|
        course_id = campus_record[COLUMN_COURSE_ID]
        ldap_id = campus_record[COLUMN_LDAP_UID]
        @campus_data_hash[course_id] = campus_record
        @campus_data_hash["#{course_id}-#{ldap_id}"] = campus_record unless ldap_id.blank?
      end
    end

    def base_file_name
      "diff_#{@dept_name.gsub(/\s/, '_')}_courses"
    end

    def headers
      '+/-,KEY,LDAP_UID,DB_COURSE_NAME,COURSE_NAME,DB_FIRST_NAME,FIRST_NAME,DB_LAST_NAME,LAST_NAME,DB_EMAIL_ADDRESS,EMAIL_ADDRESS,DB_INSTRUCTOR_FUNC,INSTRUCTOR_FUNC'
    end

    def append_records(output)
      Rails.logger.warn "Diff the CSV confirmed by #{@dept_name} dept against latest campus data."
      @aligned_rows = []
      @data_from_dept.each do |data_from_dept_row|
        ldap_uid = data_from_dept_row[COLUMN_LDAP_UID]
        course_id = data_from_dept_row[COLUMN_COURSE_ID].split('_')[0]
        key_with_ldap_uid = "#{course_id}-#{ldap_uid}" if ldap_uid
        if ldap_uid.blank? && @campus_data_hash.has_key?(course_id)
          output_diff(course_id, @campus_data_hash[course_id], data_from_dept_row, output)
        elsif @campus_data_hash.has_key? key_with_ldap_uid
          output_diff(key_with_ldap_uid, @campus_data_hash[key_with_ldap_uid], data_from_dept_row, output)
        elsif @campus_data_hash.has_key? course_id
          ignore_db_instructor = !@campus_data_hash[course_id][COLUMN_LDAP_UID].blank?
          output_diff(key_with_ldap_uid, @campus_data_hash[course_id], data_from_dept_row, output, ignore_db_instructor)
        else
          Rails.logger.warn "No campus data found for #{course_id}"
          output_diff(course_id, nil, data_from_dept_row, output)
        end
      end
      @campus_data_hash.each do |key, db_record|
        unless @aligned_rows.any? { |aligned_row| aligned_row.start_with?(key) }
          # Ignore this campus_data_hash entry if key equals {course_id} and yet hash also includes {course_id}-{ldap_uid}
          unless @campus_data_hash.has_key? "#{key}-#{db_record[COLUMN_LDAP_UID]}"
            output_diff(db_record[COLUMN_COURSE_ID], db_record, nil, output)
            Rails.logger.warn "dept_data does NOT contain course_id=#{key}"
          end
        end
      end
    end

    def output_diff(key, db_record, dept_data, output, ignore_db_instructor = false)
      @aligned_rows << key
      @columns_to_compare.each do |column_name|
        file_value = dept_data ? dept_data[column_name].to_s : nil
        db_value = db_record ? db_record[column_name].to_s : nil
        if file_value.nil? || db_value.nil? || file_value.casecmp(db_value) != 0
          row = {}
          # Row unique to edited CSV is indicated by '+'. Rows removed, relative to database, are indicated by '-'.
          diff_type_column = '+/-'
          row[diff_type_column] = ' '
          course_id = key
          ldap_uid = db_record[COLUMN_LDAP_UID] unless db_record.nil? || ignore_db_instructor
          if db_record
            if dept_data.nil?
              row[diff_type_column] = '-'
            elsif ignore_db_instructor
              row[diff_type_column] = '+'
            end
            @columns_to_compare.each do |column|
              force_nil = ignore_db_instructor && @instructor_columns.include?(column)
              db_value = db_record[column].to_s
              row["DB_#{column.upcase}"] = force_nil || db_value.blank? ? nil : db_value
            end
          end
          if dept_data
            course_id = dept_data[COLUMN_COURSE_ID]
            ldap_uid = dept_data[COLUMN_LDAP_UID] if ldap_uid.blank?
            row[diff_type_column] = '+' if db_record.nil?
            @columns_to_compare.each do |column|
              edited_value = dept_data[column].to_s
              edited_value.strip!
              row[column.upcase] = edited_value == '' ? nil : edited_value
            end
          end
          row['KEY'] = course_id
          row[COLUMN_LDAP_UID] = ldap_uid
          output << record_to_csv_row(row)
          @was_difference_found = true
          break
        end
      end
    end

    private

    def to_evaluation(row)
      course_id = row[0]
      split_course_id = course_id.split('-')
      ccn = split_course_id[2].split('_')[0]
      {
        'TERM_YR' => split_course_id[0],
        'TERM_CD' => split_course_id[1],
        'COURSE_CNTL_NUM' => ccn,
        'COURSE_ID' => course_id,
        'COURSE_NAME' => row[1],
        'CROSS_LISTED_FLAG' => row[2],
        'CROSS_LISTED_NAME' => row[3],
        'DEPT_NAME' => row[4],
        'CATALOG_ID' => row[5],
        'INSTRUCTION_FORMAT' => row[6],
        'SECTION_NUM' => row[7],
        'PRIMARY_SECONDARY_CD' => row[8],
        'LDAP_UID' => row[9],
        'FIRST_NAME' => row[10],
        'LAST_NAME' => row[11],
        'EMAIL_ADDRESS' => row[13],
        'INSTRUCTOR_FUNC' => row[14],
        'BLUE_ROLE' => row[15],
        'EVALUATE' => row[16],
        'DEPT_FORM' => row[17],
        'EVALUATION_TYPE' => row[18],
        'MODULAR_COURSE' => row[19],
        'START_DATE' => row[20],
        'END_DATE' => row[21]
      }
    end

  end
end
