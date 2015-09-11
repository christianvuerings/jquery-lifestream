module Oec
  class ReportDiffTask < Task

    attr_accessor :dept_with_diff_set
    attr_accessor :errors_per_dept

    def run_internal
      @dept_with_diff_set = Set.new
      @errors_per_dept = {}
      Oec::CourseCode.by_dept_code(@course_code_filter).keys.each { |dept_code| analyze dept_code }
    end

    def analyze(dept_code)
      dept_name = Berkeley::Departments.get(dept_code, concise: true)
      sis_data = csv_row_hash([@term_code, 'imports', datestamp, dept_name], dept_code)
      log :warn, "#{dept_code} has no #{datestamp} 'imports' spreadsheet" && return unless sis_data.any?
      dept_data = csv_row_hash([@term_code, 'departments', dept_name, 'Courses'], dept_code)
      log :warn, "#{dept_name} has no 'Courses' spreadsheet." && return unless dept_data.any?
      sis_data.keys.each do |key|
        (@dept_with_diff_set << dept_code) && return unless dept_data.has_key?(key)
        columns_to_compare.each do |column|
          (@dept_with_diff_set << dept_code) && return unless (sis_data[key][column].casecmp(dept_data[key][column]) == 0)
        end
      end
      # TODO: Implement logic below!
      # file_name = "#{timestamp}_#{Berkeley::Departments.get(dept_code, concise: true).downcase.tr(' ', '_')}_courses_diff"
      # upload_worksheet(diff_report, diff_file_name(dept_code), find_or_create_today_subfolder('reports'))
      # log :info, "#{dept_code} diff put to directory: reports/#{datestamp}"
    end

    private

    def columns_to_compare
      %w(COURSE_NAME FIRST_NAME LAST_NAME EMAIL_ADDRESS)
    end

    def csv_row_hash(folder_titles, dept_code, opts={})
      file = @remote_drive.find_nested(folder_titles, opts)
      return if file.nil?
      hash = {}
      csv = @remote_drive.export_csv file
      Oec::SisImportSheet.from_csv(csv, dept_code: dept_code).each do |row|
        next unless (id_hash = extract_id(dept_code, row))
        hash[id_hash] = row
      end
      hash
    end

    def extract_id(dept_code, row)
      errors = []
      id = hashed row
      annotation = id[:annotation]
      errors << "Invalid CCN annotation: #{annotation}" if (annotation && !%w(A B GSI CHEM MCB).include?(annotation))
      id[:ldap_uid] = row['LDAP_UID'] unless row['LDAP_UID'].blank?
      errors << "Invalid ldap_uid: #{id[:ldap_uid]}" if (id[:ldap_uid] && id[:ldap_uid].to_i <= 0)
      id[:instructor_func] = row['INSTRUCTOR_FUNC'] unless row['INSTRUCTOR_FUNC'].blank?
      errors << "Invalid instructor_func: #{id[:instructor_func]}" if (id[:instructor_func] && !(0..4).include?(id[:instructor_func].to_i))
      record_errors(dept_code, id[:ccn], errors)
      errors.any? ? nil : id
    end

    def hashed(row)
      id = row['COURSE_ID'].split '-'
      ccn_plus_tag = id[2].split '_'
      hash = { term_yr: id[0], term_cd: id[1], ccn: ccn_plus_tag[0] }
      hash[:annotation] = ccn_plus_tag[1] if ccn_plus_tag.length == 2
      hash
    end

    def record_errors(dept_code, course_id, errors)
      return unless errors.any?
      @errors_per_dept[dept_code] ||= {}
      @errors_per_dept[dept_code][course_id] ||= []
      @errors_per_dept[dept_code][course_id].concat errors
    end

  end
end
