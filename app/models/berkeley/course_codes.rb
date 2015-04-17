module Berkeley
  module CourseCodes
    extend self

    def comparable_course_code(course)
      min_code = course[:listings].map { |l| l[:course_code] }.min
      dept_name, catalog = min_code.rpartition(' ').values_at(0, 2)
      catalog_prefix, catalog_root, catalog_suffix_1, catalog_suffix_2 = catalog.match(/([A-Z]?)(\d+)([A-Z]?)([A-Z]?)/).to_a.slice(1..4)
      [dept_name, catalog_root.to_i, catalog_prefix, catalog_suffix_1, catalog_suffix_2]
    end

    def comparable_section_code(section)
      [(section[:is_primary_section] ? 0 : 1), section[:section_label]]
    end

  end
end
