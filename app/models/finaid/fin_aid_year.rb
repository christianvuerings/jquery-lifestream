module Finaid
  class FinAidYear < ActiveRecord::Base
    include ActiveRecordHelper, ClassLogger
    extend Cache::Cacheable

    # The current academic year described by this object. For example, "2013" means
    # "the academic year from the Fall 2013 term through the Summer 2014 term."
    attr_accessible :current_year

    # We always display the current aid year. On this date, we also start to display the upcoming aid year.
    # For example, starting at the end of spring break in 2014, we cover both the
    # 2013-2014 academic year and the 2014-2015 academic year.
    attr_accessible :upcoming_start_date

    validates :current_year, presence: true, uniqueness: true
    validates :upcoming_start_date, presence: true

    def self.get_upcoming_start_date(year)
      use_pooled_connection do
        if (year_row = self.find_by current_year: year)
          year_row.upcoming_start_date
        else
          nil
        end
      end
    end

  end
end
