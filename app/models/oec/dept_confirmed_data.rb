module Oec
  class DeptConfirmedData

    attr_reader :confirmed_data_per_dept
    attr_reader :warnings_per_dept

    def initialize(src_dir, departments = [])
      @confirmed_data_per_dept = {}
      @warnings_per_dept = {}
      csv_filename_suffix = '_courses_confirmed.csv'
      pattern = "#{src_dir}/*#{csv_filename_suffix}"
      csv_file_hash = {}
      Dir[pattern].each do |filename|
        dept_name = filename.split('/')[-1].chomp(csv_filename_suffix).gsub(/_/, ' ').upcase
        csv_file_hash[dept_name] = filename
      end
      biology_dept = 'BIOLOGY'
      biology_explicitly_requested = departments.include? biology_dept
      (departments.empty? ? Settings.oec.departments : departments).each do |dept_name|
        if biology_explicitly_requested && dept_name.casecmp(biology_dept) == 0
          warn(dept_name, "#{biology_dept}#{csv_filename_suffix} is not allowed. #{biology_dept} data is expected in the INTEGBI and MCELLBI files.")
        elsif csv_file_hash.has_key? dept_name
          corrected_data = []
          filename = csv_file_hash[dept_name]
          uid_per_index = {}
          CSV.read(filename).each_with_index do |row, index|
            if row.empty? || row[0].blank?
              warn(dept_name, "#{dept_name}#{csv_filename_suffix} has corrupt or missing data at row #{index + 1}")
            elsif index > 0
              converter = Oec::RowConverter.new(row)
              converter.warnings.each { |message| warn(dept_name, message) }
              hashed_row = converter.hashed_row
              ldap_uid = hashed_row['ldap_uid']
              course_id = hashed_row['course_id']
              row_uid = ldap_uid.blank? ? course_id : "#{course_id}-#{ldap_uid}"
              corrected_data << hashed_row unless uid_per_index.has_key? row_uid
              put(uid_per_index, row_uid, index)
            end
          end
          uid_per_index.each do |uid, indices|
            warn(dept_name, "#{uid} is duplicated in rows #{indices.join(', ')}") if indices.length > 1
          end
          @confirmed_data_per_dept[dept_name] = corrected_data
        elsif !departments.empty?
          warn(dept_name, "#{dept_name}#{csv_filename_suffix} not found in #{src_dir}")
        end
      end
    end

    private

    def warn(dept_name, message)
      @warnings_per_dept[dept_name] ||= {}
      put(@warnings_per_dept[dept_name], 'WARN', message)
    end

    def put(hash, key, value)
      hash[key] ||= []
      hash[key] << value
    end

  end
end
