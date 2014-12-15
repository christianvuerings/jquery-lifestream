module Oec
  class SpreadsheetComparator

    def initialize(term, dept_name)
      @term = term
      @dept_name = dept_name
    end

    def write_diff_report(file_path)
      File.open(file_path, 'w') { |file| write_report file }
    end

    def write_report(file)
      campus_records = campus_data_to_hash @dept_name
      length = campus_records.length
      if length > 0
        Rails.logger.warn "#{length} records in campus db for @term.year} #{@term.code} #{@dept_name.upcase}"
        file_path = "#{Settings.oec.export_home}/data/#{@term.year}-#{@term.code}/csv/work/#{@dept_name.upcase}_courses.csv"
        file << "KEY | COLUMN | CAMPUS_DB | DEPT_FILE\n"
        if File.file? file_path
          Rails.logger.warn "Opening CSV file: #{file_path}"
          CSV.read(file_path).each_with_index do |row, index|
            if index > 0
              file_row_hash = to_evaluation row
              course_id = file_row_hash['COURSE_ID']
              ldap_uid = file_row_hash['LDAP_UID'].to_s
              key = ldap_uid.to_s == '' ? "#{course_id}" : "#{course_id}-#{ldap_uid}"
              if campus_records.has_key? key
                db_record = campus_records[key]
                columns_to_compare.each do |column_name|
                  file_value = file_row_hash[column_name].to_s
                  db_value = db_record[column_name].to_s
                  if db_value.casecmp(file_value) != 0
                    file << "#{key} | #{column_name} | #{db_value} | #{file_value}\n"
                    Rails.logger.warn "Diff #{column_name} for #{key}:"
                    Rails.logger.warn "    campus_db: #{db_value}"
                    Rails.logger.warn "    dept_file: #{file_value}"
                  end
                end
              else
                Rails.logger.warn "No campus data found for #{key}\n"
              end
            end
          end
        else
          raise "File not found: #{file_path}"
        end
      else
        raise "No campus data where dept_name = #{@dept_name}"
      end
    end

    def campus_data_to_hash(dept_name)
      campus_records = {}
      database_records = []
      Oec::Courses.new(dept_name).append_records database_records
      database_records.each do |campus_record|
        course_id = campus_record['COURSE_ID']
        ldap_id = campus_record['LDAP_UID']
        campus_records["#{course_id}"] = campus_record
        campus_records["#{course_id}-#{ldap_id}"] = campus_record unless ldap_id.to_s == ''
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
        'FULL_NAME' => row[12],
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
