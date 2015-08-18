module Oec
  class CourseCode < ActiveRecord::Base

    self.table_name = 'oec_course_codes'
    attr_accessible :dept_name, :catalog_id, :dept_code, :include_in_oec

  end
end
