module Oec
  class CourseStudents < Export

    def initialize(ccn_set, annotated_ccn_hash, export_dir)
      super export_dir
      @ccn_set = ccn_set
      # Maps ccn to GSI, A, B, etc. (described as annotations)
      @annotated_ccn_hash = annotated_ccn_hash
    end

    def base_file_name
      'course_students'
    end

    def headers
      'COURSE_ID,LDAP_UID'
    end

    def append_records(output)
      if @ccn_set.length > 0
        Rails.logger.warn 'Get students of non-annotated CCN set'
        Oec::Queries.get_all_course_students(@ccn_set).each do |record|
          row = record_to_csv_row record
          output << row
        end
      end
      # Output must have the same annotations as in courses.csv
      if @annotated_ccn_hash.length > 0
        Rails.logger.warn 'Get students of annotated CCN set'
        Oec::Queries.get_all_course_students(@annotated_ccn_hash.keys).each do |record|
          row = record_to_csv_row record
          ccn = row['COURSE_ID'].split('-')[2].split('_')[0].to_i
          @annotated_ccn_hash[ccn].each do |annotation|
            # Do not alter row data because it will be referenced again
            row_cloned = row.clone
            row_cloned['COURSE_ID'] = "#{row_cloned['COURSE_ID']}_#{annotation}"
            output << row_cloned
          end
        end
      end

    end

  end
end
