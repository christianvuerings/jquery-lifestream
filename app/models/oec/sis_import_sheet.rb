module Oec
  class SisImportSheet < Worksheet

    attr_reader :dept_code

    def initialize(opts={})
      if (@dept_code = opts.delete :dept_code)
        opts[:export_name] = Berkeley::Departments.get(@dept_code, concise: true)
      end
      super(opts)
    end

    def headers
      %w(
        COURSE_ID
        COURSE_ID_2
        COURSE_NAME
        CROSS_LISTED_FLAG
        CROSS_LISTED_NAME
        DEPT_NAME
        CATALOG_ID
        INSTRUCTION_FORMAT
        SECTION_NUM
        PRIMARY_SECONDARY_CD
        LDAP_UID
        SIS_ID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        EVALUATE
        DEPT_FORM
        EVALUATION_TYPE
        MODULAR_COURSE
        START_DATE
        END_DATE
      )
    end

    def sorted_rows
      rows_by_cross_listing = @rows.values.group_by { |row| row['CROSS_LISTED_NAME'] }
      non_cross_listed_rows = rows_by_cross_listing.delete(nil) || []

      home_dept_names = Oec::CourseCode.dept_names_for_code(@dept_code) if @dept_code
      participating_dept_names = Oec::CourseCode.participating_dept_names

      rows_by_cross_listing.values.each do |rows|
        # If a home department is defined, move home-department rows to the top within each group of cross-listings;
        # otherwise give priority to participating departments. Then sort by department name and numeric portion of catalog id.
        rows.sort_by! do |row|
          row_priority = if home_dept_names && home_dept_names.include?(row['DEPT_NAME'])
                           0
                         elsif participating_dept_names.include? row['DEPT_NAME']
                           1
                         else
                           2
                         end
          [row_priority, row['DEPT_NAME'].to_s, row['CATALOG_ID'].try(:match, /\d+/).to_s.to_i]
        end
        # Move one representative from each cross-listed group into the set of non-cross-listed rows for sorting.
        non_cross_listed_rows << rows.shift
      end

      non_cross_listed_rows.sort_by! do |row|
        # Sort by department name first and numeric portion of catalog id second.
        [row['DEPT_NAME'].to_s, row['CATALOG_ID'].try(:match, /\d+/).to_s.to_i]
      end

      # Merge in the remaining cross-listings.
      rows_by_cross_listing.each do |cross_listed_name, rows|
        cross_listing_index = non_cross_listed_rows.index { |row| row['CROSS_LISTED_NAME'] == cross_listed_name }
        non_cross_listed_rows.insert(cross_listing_index + 1, *rows)
      end
      non_cross_listed_rows
    end

  end
end
