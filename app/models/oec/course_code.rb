module Oec
  class CourseCode < ActiveRecord::Base

    self.table_name = 'oec_course_codes'
    attr_accessible :dept_name, :catalog_id, :dept_code, :include_in_oec

    def self.by_dept_code(opts)
      self.where(opts).group_by { |course_code| course_code.dept_code }
    end

    def self.included_dept_names
      self.where(include_in_oec: true).select(:dept_name).uniq
    end

    def self.included?(dept_name, catalog_id)
      course_code = find_code(dept_name, catalog_id)
      course_code.present? && course_code.include_in_oec
    end

    def self.find_code(dept_name, catalog_id)
      find_by(dept_name: dept_name, catalog_id: catalog_id) || find_by(dept_name: dept_name, catalog_id: '')
    end

  end
end
