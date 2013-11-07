class Instructors < OecExport

  def initialize(ccns)
    super()
    @ccns = ccns
  end

  def base_file_name
    "instructors"
  end

  def headers
    'LDAP_UID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,BLUE_ROLE'
  end

  def append_records(output)
    OecData.get_all_instructors(@ccns).each do |instructor|
      output << record_to_csv_row(instructor)
    end
  end

end
