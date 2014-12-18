module Oec
  class CourseStudents < Export

    def initialize(ccns, gsi_ccns, export_dir)
      super export_dir
      @ccns = ccns
      @gsi_ccns = gsi_ccns
    end

    def base_file_name
      'course_students'
    end

    def headers
      'COURSE_ID,LDAP_UID'
    end

    def append_records(output)
      if @ccns.length > 0
        Oec::Queries.get_all_course_students(@ccns).each do |record|
          row = record_to_csv_row record
          output << row
        end
      end

      # now add in courses with _GSI suffix (might duplicate some of the ones already in the file, but that's ok.)
      if @gsi_ccns.length > 0
        Oec::Queries.get_all_course_students(@gsi_ccns).each do |record|
          row = record_to_csv_row record
          row['COURSE_ID'] = "#{row['COURSE_ID']}_GSI"
          output << row
        end
      end

    end

  end
end
