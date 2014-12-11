module Oec
  class Students < Export

    def initialize(ccns, gsi_ccns)
      super()
      @ccns = ccns
      @gsi_ccns = gsi_ccns
    end

    def base_file_name
      'students'
    end

    def headers
      'LDAP_UID,FIRST_NAME,LAST_NAME,FULL_NAME,EMAIL_ADDRESS'
    end

    def append_records(output)
      ccn_set = @ccns.to_set
      ccn_set.merge @gsi_ccns
      append_student_records(output, ccn_set) unless ccn_set.empty?
    end

    def append_student_records(output, ccns)
      Oec::Queries.get_all_students(ccns).each do |student|
        output << record_to_csv_row(student)
      end
    end

  end
end
