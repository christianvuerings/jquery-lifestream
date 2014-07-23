module Berkeley
  class Term
    include ActiveAttr::Model, ClassLogger
    extend Cache::Cacheable

    attr_reader :code
    attr_reader :name
    attr_reader :slug
    attr_reader :year
    # The campus DB tables store the first and last days of instruction for Fall and Spring,
    # and the start and end dates of the Summer Sessions.
    attr_reader :classes_start
    attr_reader :classes_end
    # the end of instruction is 1 week after classes end; the week between is RRR week.
    attr_reader :instruction_end
    # The Academic Calendar shows Fall/Spring semesters beginning one week before classes.
    attr_reader :start
    # The Fall/Spring semesters end after a week of final exams.
    attr_reader :end

    def initialize(db_row)
      term_cd = db_row['term_cd']
      term_yr = db_row['term_yr'].to_i
      @code = term_cd
      @name = db_row['term_name']
      @year = term_yr
      @slug = TermCodes.to_slug(term_yr, term_cd)
      @classes_start = db_row['term_start_date'].to_date.in_time_zone.to_datetime
      @instruction_end = db_row['term_end_date'].to_date.in_time_zone.to_datetime.end_of_day
      if term_cd == 'C'
        @start = @classes_start
        @end = @instruction_end
        @classes_end = @instruction_end
      else
        @start = @classes_start.advance(days: -7)
        @end = @instruction_end.advance(days: 7)
        @classes_end = @instruction_end.advance(days: -7)
      end
    end

    def to_english
      TermCodes.to_english(year, code)
    end

    # Most final grades should appear on the transcript by this date.
    def grades_entered
      @end.advance(weeks: 3, days: 2)
    end
  end
end
