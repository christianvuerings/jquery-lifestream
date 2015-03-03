module Oec
  class CoursesDiff < Export

    COLUMN_LDAP_UID = 'ldap_uid'
    COLUMN_COURSE_ID = 'course_id'
    COLUMN_INSTRUCTOR_FUNC = 'instructor_func'

    # true if course data provided by dept representative differs from campus db data
    attr_reader :was_difference_found
    attr_reader :errors_per_course_id

    def initialize(dept_name, campus_data, data_from_dept, export_dir)
      super export_dir
      @was_difference_found = false
      @errors_per_course_id = {}
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
      courses_csv_file = "#{@dept_name}_courses_confirmed.csv"
      Rails.logger.info "Start diff on #{courses_csv_file}"
      @aligned_rows = []
      @data_from_dept.each do |data_from_dept_row|
        id_hash = create_id_hash data_from_dept_row
        unless id_hash.nil?
          course_id = "#{id_hash[:term_yr]}-#{id_hash[:term_cd]}-#{id_hash[:ccn]}"
          ldap_uid = id_hash[:ldap_uid]
          key_with_ldap_uid = "#{course_id}-#{ldap_uid}" unless ldap_uid.blank?
          if ldap_uid.blank? && @campus_data_hash.has_key?(course_id)
            output_diff(course_id, @campus_data_hash[course_id], data_from_dept_row, output)
          elsif @campus_data_hash.has_key? key_with_ldap_uid
            output_diff(key_with_ldap_uid, @campus_data_hash[key_with_ldap_uid], data_from_dept_row, output)
          elsif @campus_data_hash.has_key? course_id
            ignore_db_instructor = !@campus_data_hash[course_id][COLUMN_LDAP_UID].blank?
            output_diff(key_with_ldap_uid, @campus_data_hash[course_id], data_from_dept_row, output, ignore_db_instructor)
          else
            report_errors(course_id, ["Campus-db has NO record for #{course_id} (ldap_uid=#{ldap_uid}) as found in #{courses_csv_file}"])
            output_diff(course_id, nil, data_from_dept_row, output)
          end
        end
      end
      @campus_data_hash.each do |key, db_record|
        unless @aligned_rows.any? { |aligned_row| aligned_row.start_with?(key) }
          # Ignore this campus_data_hash entry if key equals {course_id} and yet hash also includes {course_id}-{ldap_uid}
          ldap_uid = db_record[COLUMN_LDAP_UID]
          unless @campus_data_hash.has_key? "#{key}-#{ldap_uid}"
            course_id = db_record[COLUMN_COURSE_ID]
            output_diff(course_id, db_record, nil, output)
            report_errors(course_id, ["#{courses_csv_file} does NOT contain course_id=#{course_id} with ldap_uid=#{ldap_uid}"])
          end
        end
      end
      Rails.logger.info "Diff file generated per #{courses_csv_file}" if @was_difference_found
      Rails.logger.info "No diff to report on #{courses_csv_file}" unless @was_difference_found
    end

    private

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
              edited_value = dept_data[column].to_s.strip
              row[column.upcase] = edited_value.blank? ? nil : edited_value
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

    def create_id_hash(row)
      annotated_course_id = row[COLUMN_COURSE_ID]
      id_hash = create_course_id_hash annotated_course_id
      errors = []
      term = Settings.oec.current_terms_codes[0]
      errors << "YEAR is invalid: #{id_hash[:term_yr]}" if id_hash[:term_yr].to_i != term.year
      errors << "TERM is invalid: #{id_hash[:term_cd]}" if id_hash[:term_cd] != term.code
      errors << "CCN is invalid: #{id_hash[:ccn]}" unless id_hash[:ccn].to_i > 0
      annotation = id_hash[:annotation]
      if annotation
        errors << "CCN annotation is invalid: #{annotation}" unless %w(A B GSI CHEM MCB).include? annotation
      end
      ldap_uid = row[COLUMN_LDAP_UID]
      unless ldap_uid.blank?
        id_hash[:ldap_uid] = ldap_uid
        errors << "LDAP_UID is invalid: #{ldap_uid}" unless ldap_uid.to_i > 0
      end
      instructor_func = row[COLUMN_INSTRUCTOR_FUNC]
      unless instructor_func.blank?
        id_hash[:instructor_func] = instructor_func
        errors << "INSTRUCTOR_FUNC is invalid: #{instructor_func}" unless (0..4).include? instructor_func.to_i
      end

      report_errors(annotated_course_id, errors)
      errors.any? ? nil : id_hash
    end

    def report_errors(course_id, errors = [])
      if errors.any?
        @errors_per_course_id[course_id] ||= []
        @errors_per_course_id[course_id].concat errors
      end
    end

    def create_course_id_hash(annotated_course_id)
      id_hash = {}
      split_course_id = annotated_course_id.split '-'
      id_hash[:term_yr] = split_course_id[0]
      id_hash[:term_cd] = split_course_id[1]
      ccn_annotated = split_course_id[2].split '_'
      id_hash[:ccn] = ccn_annotated[0]
      id_hash[:annotation] = ccn_annotated[1] if ccn_annotated.length == 2
      id_hash
    end

  end
end
