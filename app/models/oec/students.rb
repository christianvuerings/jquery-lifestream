module Oec
  class Students < Export

    def initialize(ccn_set, annotated_ccn_hash, export_dir)
      super export_dir
      # Annotations allow for categories within a given course-id. For example, instructor types: primary, GSI, etc.
      @ccn_set = ccn_set | annotated_ccn_hash.keys
    end

    def base_file_name
      'students'
    end

    def headers
      'LDAP_UID,SIS_ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS'
    end

    def append_records(output)
      unless @ccn_set.empty?
        Oec::Queries.get_all_students(@ccn_set).each do |student|
          output << record_to_csv_row(student)
        end
      end
    end

  end
end
