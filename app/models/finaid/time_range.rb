module Finaid
  module TimeRange
    extend self, Cache::Cacheable
    include ClassLogger

    def current_years
      now = Settings.terms.fake_now || DateTime.now.in_time_zone
      fetch_from_cache do
        years = []
        terms = Berkeley::Terms.fetch
        # We use the current term's official end year rather than the current time's year
        # to deal with Spring 2015 being "current" on December 30, 2014.
        current_year = terms.current.end.year
        case terms.current.name
          when 'Spring', 'Summer'
            years.push(current_year)
            if (date_to_show_next_year = FinAidYear.get_upcoming_start_date current_year)
              if now >= date_to_show_next_year.in_time_zone.to_datetime
                next_year = current_year + 1
                years.push(next_year)
                # If the next year's transition hasn't been recorded yet in the DB,
                # issue a stern reminder. We have less than five months to add it.
                unless FinAidYear.get_upcoming_start_date(next_year)
                  logger.fatal("No FinAidYear record for academic year #{next_year} yet! Please obtain it from the academic calendar and add it to the CalCentral DB ASAP!")
                end
              end
            end
          when 'Fall'
            current_year += 1
            years.push(current_year)
        end
        years
      end
    end

    def cutoff_date
      now = Settings.terms.fake_now || DateTime.now.in_time_zone
      now.advance(years: -1)
    end

  end
end

