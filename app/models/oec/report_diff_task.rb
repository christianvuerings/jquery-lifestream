module Oec
  class ReportDiffTask < Task

    include Validator

    attr_accessor :diff_report

    def run_internal
      @diff_report = Oec::DiffReport.new @opts
      Oec::CourseCode.by_dept_code(@course_code_filter).keys.each { |dept_code| analyze dept_code }
      update_remote_drive
      log_validation_errors
    end

    private

    def update_remote_drive
      departments_folder = @remote_drive.find_nested([@term_code, 'departments'])
      raise RuntimeError, "No departments folder found for term #{@term_code}" unless departments_folder
      title = "#{@term_code} diff report"
      if (remote_file = @remote_drive.find_first_matching_item(title, departments_folder))
        # TODO: Be transactional, implement @remote_drive.update_worksheet(). For now, the benefit is not worth the risk of refactor.
        log :info, "Permanently delete the old diff report #{remote_file.id}"
        @remote_drive.trash_item(remote_file, permanently_delete: true)
      end
      upload_worksheet(@diff_report, title, departments_folder)
    end

    def analyze(dept_code)
      dept_name = Berkeley::Departments.get(dept_code, concise: true)
      validate(dept_code, @term_code) do |errors|
        sis_data = csv_row_hash([@term_code, 'imports', "#{datestamp} #{timestamp}", dept_name], dept_code, Oec::SisImportSheet)
        errors.add("#{dept_name} has no 'imports' '#{datestamp} #{timestamp}' spreadsheet") && return unless sis_data
        dept_data = csv_row_hash([@term_code, 'departments', dept_name], dept_code, Oec::CourseConfirmation)
        errors.add("#{dept_name} has no department confirmation spreadsheet") && return unless dept_data
        keys_of_rows_with_diff = []
        intersection = (sis_keys = sis_data.keys) & (dept_keys = dept_data.keys)
        (sis_keys | dept_keys).select do |key|
          if intersection.include? key
            column_with_diff = columns_to_compare.detect do |column|
              # Anticipate nil column values
              sis_value = sis_data[key][column].to_s
              dept_value = dept_data[key][column].to_s
              sis_value.casecmp(dept_value) != 0
            end
            keys_of_rows_with_diff << key if column_with_diff
          else
            keys_of_rows_with_diff << key
          end
        end
        log :info, "#{keys_of_rows_with_diff.length} row(s) with diff found in #{@term_code}/departments/#{dept_name}"
        report_diff(dept_code, sis_data, dept_data, keys_of_rows_with_diff)
      end
    end

    def default_date_time
      date_time_of_most_recent 'imports'
    end

    def report_diff(dept_code, sis_data, dept_data, keys)
      keys.each do |key|
        sis_row = sis_data[key]
        dept_row = dept_data[key]
        ldap_uid = sis_row ? sis_row['LDAP_UID'] : dept_row['LDAP_UID']
        id = "#{key[:term_yr]}-#{key[:term_cd]}-#{key[:ccn]}"
        id << "-#{key[:ldap_uid]}" unless key[:ldap_uid].to_s.empty?
        diff_row = {
          '+/-' => diff_type_symbol(sis_row, dept_row),
          'DEPT_CODE' => dept_code,
          'KEY' => id,
          'LDAP_UID' => ldap_uid
        }
        columns_to_compare.each do |column|
          diff_row["sis:#{column}"] = sis_row ? sis_row[column] : nil
          diff_row[column] = dept_row ? dept_row[column] : nil
        end
        @diff_report[key] = diff_row
      end
    end

    def diff_type_symbol(sis_row, dept_row)
      return ' ' if sis_row && dept_row
      dept_row ? '+' : '-'
    end

    def columns_to_compare
      %w(COURSE_NAME FIRST_NAME LAST_NAME EMAIL_ADDRESS DEPT_FORM EVALUATION_TYPE MODULAR_COURSE START_DATE END_DATE)
    end

    def csv_row_hash(folder_titles, dept_code, klass)
      return unless (file = @remote_drive.find_nested(folder_titles, @opts))
      hash = {}
      csv = @remote_drive.export_csv file
      klass.from_csv(csv, dept_code: dept_code).each do |row|
        begin
          row = Oec::Worksheet.capitalize_keys row
          id = extract_id row
          validate(dept_code, id[:ccn]) do |errors|
            report(errors, id, :annotation, false, %w(A B GSI CHEM MCB))
            report(errors, id, :ldap_uid, false, (1..99999999))
            report(errors, row, 'EVALUATION_TYPE', false, %w(F G))
            report(errors, row, 'MODULAR_COURSE', false, %w(Y N y n))
            report(errors, row, 'START_DATE', true)
            report(errors, row, 'END_DATE', true)
          end
          hash[id] = row
        rescue => e
          log :error, "\nThis row with bad data in #{folder_titles} will be ignored: \n#{row}."
          log :error, "We will NOT abort; the error is NOT fatal: #{e.message}"
        end
      end
      hash
    rescue => e
      # We do not tolerate fatal errors when loading CSV file.
      log :error, "\nBoom! Crash! Fatal error in csv_row_hash(#{folder_titles}, #{dept_code}, #{klass})\n"
      raise e
    end


    def report(errors, hash, key, required, range=nil)
      value = (range && range.first.is_a?(Numeric) && /\A\d+\z/.match(hash[key])) ? hash[key].to_i : hash[key]
      return if value.blank? && !required
      unless range.nil? || range.include?(value)
        errors.add(value.nil? ? "#{key} is blank" : "Invalid #{key}: #{value}")
      end
    end

    def extract_id(row)
      id = row['COURSE_ID'].split '-'
      ccn_plus_tag = id[2].split '_'
      hash = { term_yr: id[0], term_cd: id[1], ccn: ccn_plus_tag[0] }
      hash[:annotation] = ccn_plus_tag[1] if ccn_plus_tag.length == 2
      hash[:ldap_uid] = row['LDAP_UID'] unless row['LDAP_UID'].blank?
      hash
    end

  end
end
