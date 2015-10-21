module Oec
  class CourseInstructors < Worksheet

    def headers
      %w(
        COURSE_ID
        LDAP_UID
      )
    end

    def uids_for_course_id(course_id)
      ids = []
      self.each { |row| ids << row['LDAP_UID'] if row['COURSE_ID'] == course_id }
      ids
    end

  end
end
