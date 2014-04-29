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

    def self.stringify_ints!(results, additional_columns=[])
      columns = ["ldap_uid", "student_id", "term_yr", "catalog_root", "course_cntl_num", "student_ldap_uid"] + additional_columns
      if results.respond_to?(:to_ary)
        result_array = results.to_ary
        result_array.each do |row|
          stringify_row!(row, columns)
        end
        return result_array
      else
        return stringify_row!(results, columns)
      end
    end

    def self.stringify_row!(row, columns)
      return row unless row
      columns.each do |column|
        if row[column]
          row[column] = row[column].to_i.to_s
        end
      end
      row
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

  end
end
