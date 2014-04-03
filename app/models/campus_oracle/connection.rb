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
          clause.concat("(#{table}.term_cd=#{connection.quote(terms[idx].term_cd)} and #{table}.term_yr=#{terms[idx].term_yr.to_i})")
        end
        clause.concat(')')
        clause
      else
        ''
      end
    end

    def self.translate_records(results, additional_columns=[])
      result_array = results.to_ary
      result_array.each do |row|
        translate_single_row!(row, additional_columns)
      end
      result_array
    end

    def self.translate_single_row!(row, additional_columns=[])
      columns = ["ldap_uid", "student_id"] + additional_columns
      columns.each do |column|
        row[column] = row[column].to_i.to_s
      end
      row
    end

  end
end
