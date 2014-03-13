class OracleDatabase < ActiveRecord::Base
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

end
