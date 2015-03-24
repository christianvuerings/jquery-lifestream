module CampusOracle
  class Connection < ActiveRecord::Base
    # WARNING: Default Rails SQL query caching (done for the lifetime of a controller action) apparently does not apply
    # to anything but the primary DB connection. Any Oracle query caching needs to be handled explicitly.
    establish_connection "campusdb"

    def self.test_data?
      Settings.campusdb.adapter == "h2"
    end

    def self.terms_query_clause(table, terms)
      if !terms.blank?
        clause = 'and ('
        terms.each_index do |idx|
          clause.concat(' or ') if idx > 0
          clause.concat("(#{table}.term_cd=#{connection.quote(terms[idx].code)} and #{table}.term_yr=#{terms[idx].year.to_i})")
        end
        clause.concat(')')
        clause
      else
        ''
      end
    end

    def self.depts_clause(table, departments, inclusive = true)
      string = if departments.blank?
                 ''
               else
                 clause = "and #{table}.dept_name #{'NOT' unless inclusive} IN ("
                 departments.each_with_index do |dept, index|
                   clause.concat("'#{dept}'")
                   clause.concat(",") unless index == departments.length - 1
                 end
                 clause.concat(')')
                 clause
               end
      string
    end

    def self.stringify_ints!(results, additional_columns=[])
      columns = %w(ldap_uid student_id term_yr catalog_root course_cntl_num student_ldap_uid) + additional_columns
      if results.respond_to?(:to_ary)
        results.to_ary.each { |row| stringify_row!(row, columns) }
      else
        stringify_row!(results, columns)
      end
    end

    def self.stringify_row!(row, columns)
      columns.each { |column| stringify_column!(row, column) }
      row
    end

    def self.stringify_column!(row, column)
      if row && row[column]
        if column == 'course_cntl_num'
          row[column] = '%05d' % row[column].to_i
        else
          row[column] = row[column].to_i.to_s
        end
      end
    end

    # Oracle and H2 have no timestamp formatting function in common.
    def self.timestamp_format(timestamp_column)
      if test_data?
        "formatdatetime(#{timestamp_column}, 'yyyy-MM-dd HH:mm:ss')"
      else
        "to_char(#{timestamp_column}, 'yyyy-mm-dd hh24:mi:ss')"
      end
    end

    def self.timestamp_parse(datetime)
      if test_data?
        "parsedatetime('#{datetime.utc.to_s(:db)}', 'yyyy-MM-dd HH:mm:ss')"
      else
        "to_date('#{datetime.utc.to_s(:db)}', 'yyyy-mm-dd hh24:mi:ss')"
      end
    end

    def self.filter_multi_entry_codes(results)
      # if a course has multiple schedule entries, and the first one's PRINT_CD = "A",
      # then do not display other rows for that course.
      # page 15 of the Class Scheduler User's Guide explains the rationale for this horror:
      # http://registrar.berkeley.edu/DisplayMedia.aspx?ID=Class_Sched_Users_Guide.pdf
      filtered_rows = []
      current_ccn = nil
      current_ccns_first_print_cd = nil
      is_first_row = false
      results.each do |row|
        if current_ccn != row['course_cntl_num']
          current_ccn = row['course_cntl_num']
          current_ccns_first_print_cd = row['print_cd']
          is_first_row = true
        end
        if is_first_row || current_ccns_first_print_cd != 'A'
          filtered_rows << row
        end
        is_first_row = false
      end
      filtered_rows
    end

  end
end
