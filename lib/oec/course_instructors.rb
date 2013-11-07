class CourseInstructors < OecExport

  def initialize(ccns)
    super()
    @ccns = ccns
  end

  def base_file_name
    "course_instructors"
  end

  def headers
    'COURSE_ID,LDAP_UID,INSTRUCTOR_FUNC'
  end

  def append_records(output)
    OecData.get_all_course_instructors(@ccns).each do |record|
      output << record_to_csv_row(record)
    end
  end

end
