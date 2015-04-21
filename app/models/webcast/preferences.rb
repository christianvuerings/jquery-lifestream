module Webcast
  class Preferences < ActiveRecord::Base

    self.table_name = 'webcast_preferences'

    attr_accessible :year, :term_cd, :ccn, :opt_out

  end
end
