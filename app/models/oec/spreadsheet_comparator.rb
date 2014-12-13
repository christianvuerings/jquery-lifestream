module Oec
  class SpreadsheetComparator

    def initialize(term, dept_name)
      @term = term
      @dept_name = dept_name
      file_path = "#{Settings.oec.export_home}/data/#{term.year}-#{term.code}/csv/work/#{dept_name.upcase}_courses.csv"
      @dept_edits = courses_csv_to_hash file_path
      @campus_records = campus_data_to_hash dept_name
    end

    def write_diff_report(file_path)
      File.open(file_path, 'w') { |file| write_report file }
    end

    def write_report(file)
      @dept_edits.each do |key, dept_edit|
        campus_record = @campus_records[key]
        if campus_record
          columns_to_compare.each do |column_name|
            campus_column = campus_record[column_name].to_s
            modification = dept_edit[column].to_s
            casecmp = campus_column.casecmp modification
            output << "COMPARE campus_column=#{campus_column.to_s} : modification=#{modification}"
            if casecmp
              file << "SAME per column=#{column_name} where key=#{key}"
            else
              file << "DIFF per column=#{column_name} where key=#{key}"
              break
              # Rails.logger.warn '--------------------------'
              # Rails.logger.warn "key: #{key}"
              # Rails.logger.warn "authoritative: #{campus_record}"
              # Rails.logger.warn "dept_edit: #{dept_edit}"
            end
          end
        else
          file << "No campus data found for #{key}"
        end
      end
    end

    def campus_data_to_hash(dept_name)
      campus_records = {}
      database_records = []
      Oec::Courses.new(dept_name).append_records database_records
      database_records.each do |campus_record|
        campus_records[courses_hash_key campus_record] = campus_record
      end
      campus_records
    end

    def courses_csv_to_hash(csv_path)
      courses_hash = {}
      if File.file? csv_path
        Rails.logger.warn "Opening CSV file: #{csv_path}"
        CSV.read(csv_path).each_with_index do |row, index|
          if index > 0
            row_as_hash = to_evaluation row
            courses_hash[courses_hash_key row_as_hash] = row_as_hash
          end
        end
      else
        raise "File not found: #{csv_path}"
      end
      courses_hash
    end

    def to_evaluation(row)
      course_id = row[0]
      split_course_id = course_id.split('-')
      ccn = split_course_id[2].split('_')[0]
      {
        'term_yr' => split_course_id[0],
        'term_cd' => split_course_id[1],
        'course_cntl_num' => ccn,
        'course_id' => course_id,
        'course_name' => row[1],
        'cross_listed_flag' => row[2],
        'cross_listed_name' => row[3],
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
        'dept_form' => row[17],
        'evaluation_type' => row[18],
        'modular_course' => row[19],
        'start_date' => row[20],
        'end_date' => row[21]
      }
    end

    def columns_to_compare
      %w('course_name' 'cross_listed_name' 'dept_name' 'catalog_id' 'instruction_format' 'section_num' 'primary_secondary_cd' 'first_name' 'last_name' 'full_name' 'email_address' 'instructor_func')
    end

    def courses_hash_key(hash)
      "#{hash['course_id']}-#{hash['ldap_uid']}"
    end

  end
end
