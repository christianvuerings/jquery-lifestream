module Webcast
  class Preferences < ActiveRecord::Base

    self.table_name = 'webcast_preferences'

    attr_accessible :year, :term_cd, :ccn, :opt_out

    def self.lookup(year, term_cd, ccn)
      result_set = Preferences.limit(1).where(
        'year = :year AND term_cd = :term_cd AND ccn = :ccn',
        {
          year: year,
          term_cd: term_cd,
          ccn: ccn
        })
      result_set[0]
    end

  end
end
