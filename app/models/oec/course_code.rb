module Oec
  class CourseCode < ActiveRecord::Base

    self.table_name = 'oec_course_codes'
    attr_accessible :dept_name, :catalog_id, :dept_code, :include_in_oec

    def self.by_dept_code(opts)
      self.where(opts).group_by { |course_code| course_code.dept_code }
    end

    def self.catalog_id_specific_mapping(dept_name, catalog_id)
      # Cached retrieval for the small number of mappings, such as BIOLOGY 1A/1B, that depend on specific catalog IDs.
      @catalog_id_specific_mappings ||= Oec::CourseCode.where.not(catalog_id: '').to_a
      @catalog_id_specific_mappings.find { |m| m.dept_name == dept_name && m.catalog_id == catalog_id }
    end

    def self.included?(dept_name, catalog_id)
      course_code = find_code(dept_name, catalog_id)
      course_code.present? && course_code.include_in_oec
    end

    def self.find_code(dept_name, catalog_id)
      find_by(dept_name: dept_name, catalog_id: catalog_id) || find_by(dept_name: dept_name, catalog_id: '')
    end

    def matches_row?(row)
      self.dept_name == row['DEPT_NAME'] && (self.catalog_id == row['CATALOG_ID'] || self.catalog_id.blank?)
    end

  end
end
