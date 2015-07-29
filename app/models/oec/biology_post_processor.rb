module Oec
  class BiologyPostProcessor

    attr_reader :csv_per_dept

    def initialize(src_dir, dest_dir, debug_mode = false)
      @src_dir = src_dir
      @dest_dir = dest_dir
      @debug_mode = debug_mode
      @csv_per_dept = {}
    end

    def post_process
      dept_registry = Oec::DepartmentRegistry.new
      biology = Oec::Courses.new(dept_registry.biology_dept_name, @src_dir)
      path_to_biology_csv = biology.output_filename
      if File.exist? path_to_biology_csv
        files_to_archive = { dept_registry.biology_dept_name => path_to_biology_csv }
        uids_in_target_files = {}
        sorted_dept_rows = {}
        dept_registry.biology_relationship_matchers.keys.each do |target_dept_name|
          path_to_target_csv = Oec::Courses.new(target_dept_name, @src_dir).output_filename
          files_to_archive[target_dept_name] = path_to_target_csv
          uids_in_target_files[target_dept_name] = []
          Oec::Csv.read(path_to_target_csv).each_with_index do |row, index|
            unless index == 0
              uids_in_target_files[target_dept_name] << "#{get_row_uid row}"
              put_row_per_dept(sorted_dept_rows, target_dept_name, row)
            end
          end
        end
        Oec::Csv.read(path_to_biology_csv).each_with_index do |row, index|
          unless preexisting_uid?(get_row_uid(row), uids_in_target_files, files_to_archive.keys) || index == 0
            course_name = row[1]
            target_csv = dept_registry.biology_dept_name
            dept_registry.biology_relationship_matchers.each do |dept_name, pattern|
              if course_name.match(pattern).present?
                target_csv = row[4] = dept_name
              end
            end
            put_row_per_dept(sorted_dept_rows, target_csv, row)
          end
        end
        files_to_archive.each do | next_dept_name, path_to_csv |
          @debug_mode ? FileUtils.mv(path_to_csv, "#{path_to_csv}.OBSOLETE") : File.delete(path_to_csv)
          rows = sorted_dept_rows[next_dept_name]
          if rows && rows.length > 0
            wrapper = ExportWrapper.new(next_dept_name, biology.headers, rows, @dest_dir)
            wrapper.export
            @csv_per_dept[next_dept_name] = wrapper.output_filename
          end
        end
      else
        Rails.logger.error "File not found: #{path_to_biology_csv}"
      end
    end

    private

    def put_row_per_dept(dept_rows_hash, dept_name, row)
      dept_rows_hash[dept_name] ||= []
      dept_rows_hash[dept_name] << row
    end

    def preexisting_uid?(uid, pre_existing_uid, dept_names)
      dept_names.each do |dept_name|
        dept_uids = pre_existing_uid[dept_name]
        if dept_uids && dept_uids.include?(uid)
          Rails.logger.debug "Skip row #{uid} in BIOLOGY data-set because #{dept_name} has accounted for that course."
          return true
        end
      end
      false
    end

    def get_row_uid(row)
      "#{row[0]}-#{row[9]}"
    end

  end

  class ExportWrapper < Oec::Courses

    def initialize(dept_name, header_row, rows, export_dir)
      super(dept_name, export_dir)
      @header_row = header_row
      @rows = rows
    end

    def headers
      @header_row
    end

    def append_records(output)
      @rows.each do |row|
        output << row
      end
    end

  end
end
