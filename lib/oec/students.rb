class Students < OecExport

  def initialize(ccns, gsi_ccns)
    super()
    @ccns = ccns
    @gsi_ccns = gsi_ccns
  end

  def base_file_name
    "students"
  end

  def headers
    'LDAP_UID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS'
  end

  def append_records(output)
    OecData.get_all_students(@ccns).each do |student|
      output << record_to_csv_row(student)
    end
  end

end
