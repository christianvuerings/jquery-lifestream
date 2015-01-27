module Oec
  class CoursesDiff < Export

    def initialize(dept_name, source_dir, export_dir)
      super export_dir
      @source_dir = source_dir
      @dept_name = dept_name.upcase
    end

    def base_file_name
      "#{@dept_name.gsub(/\s/, '_')}_courses_confirmed"
    end

    def headers
      '+/-,KEY,DB_COURSE_NAME,COURSE_NAME,DB_FIRST_NAME,FIRST_NAME,DB_LAST_NAME,LAST_NAME,DB_EMAIL_ADDRESS,EMAIL_ADDRESS,DB_INSTRUCTOR_FUNC,INSTRUCTOR_FUNC'
    end

    def append_records(output)
      campus_records = campus_data_to_hash @dept_name
      length = campus_records.length
      Rails.logger.warn "#{length} records in campus db for #{@dept_name}"
      if length > 0
        keys_matching = []
        edited_courses = Oec::Queries.get_edited_courses(@source_dir, @dept_name)
        edited_courses.each do |edited_course|
          Rails.logger.warn "Next edited_course: #{edited_course.to_s}"
          course_id = edited_course['course_id']
          ldap_uid = edited_course['ldap_uid'].to_s
          primary_key = ldap_uid == '' ? "#{course_id}" : "#{course_id}-#{ldap_uid}"
          if campus_records.has_key? primary_key
            keys_matching << primary_key
            db_record = campus_records[primary_key]
            columns_to_compare.each do |column_name|
              file_value = edited_course[column_name.downcase].to_s
              db_value = db_record[column_name].to_s
              if db_value.casecmp(file_value) != 0
                diff = get_diff_row(primary_key, edited_course, db_record)
                Rails.logger.warn "Diff found: #{diff.to_s}"
                output << record_to_csv_row(diff)
                break
              end
            end
          else
            Rails.logger.warn "No campus data found for #{primary_key}"
            diff = get_diff_row(primary_key, edited_course, nil)
            output << record_to_csv_row(diff)
          end
        end
        campus_records.each do |course_id, db_record|
          ldap_uid = db_record['ldap_uid'].to_s
          primary_key = ldap_uid == '' ? "#{course_id}" : "#{course_id}-#{ldap_uid}"
          unless keys_matching.include? primary_key
            diff = get_diff_row(primary_key, nil, db_record)
            output << record_to_csv_row(diff)
            Rails.logger.warn "edited_course does NOT contain course_id=#{primary_key}"
          end
        end
        Rails.logger.warn "Diff results written to: #{export_directory}"
      else
        Rails.logger.warn "No campus data where dept_name = #{@dept_name}"
      end
    end

    def get_diff_row(primary_key, edited_course, db_record)
      row = {}
      # Row unique to edited CSV is indicated by '+'. Rows removed, relative to database, are indicated by '-'.
      diff_type_column = '+/-'
      row[diff_type_column] = ' '
      row['KEY'] = primary_key
      if db_record
        row[diff_type_column] = '-' if edited_course.nil?
        columns_to_compare.each do |column|
          db_value = db_record[column].to_s
          row["DB_#{column}"] = db_value == '' ? nil : db_value
        end
      end
      if edited_course
        row[diff_type_column] = '+' if db_record.nil?
        columns_to_compare.each do |column|
          edited_value = edited_course[column.downcase].to_s
          edited_value.strip!
          row[column] = edited_value == '' ? nil : edited_value
        end
      end
      row
    end

    def campus_data_to_hash(dept_name)
      campus_records = {}
      database_records = []
      Oec::Courses.new(dept_name, export_directory).append_records database_records
      database_records.each do |campus_record|
        course_id = campus_record['COURSE_ID']
        ldap_id = campus_record['LDAP_UID']
        empty_ldap_uid = ldap_id.to_s == ''
        campus_records["#{course_id}"] = campus_record if empty_ldap_uid
        campus_records["#{course_id}-#{ldap_id}"] = campus_record unless empty_ldap_uid
      end
      campus_records
    end

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

    def columns_to_compare
      %w(COURSE_NAME FIRST_NAME LAST_NAME EMAIL_ADDRESS INSTRUCTOR_FUNC)
    end

  end
end
