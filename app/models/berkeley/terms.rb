# Our campus DB may contain data for many semesters excluded from CalCentral. Semesters of interest vary by
# functional domain:
#
#   * My Academics :
#       - Currently running term (if any; there are gaps between terms)
#       - Past terms back to a configured cut-off
#       - The next term, when available
#       - In Spring, the next Fall term, when available
#   * My Classes :
#       - Currently running term, if any; otherwise the next term
#   * bCourses course provisioning & refreshes :
#       - Currently running term (if any)
#       - The next term, when available
#       - In Spring, the next Fall term, when available
#   * FinAid :
#       - Always display the "current Aid Year", which is defined as:
#           - After the end of the Summer term, the next calendar year
#           - Up to and including the last day of this year's Summer term, the current calendar year
#       - Also display the "next Aid Year" between "the day admissions letters are released"
#         and the last day of Summer term. The admissions-release day is not available in the
#         campus DB, and so it is maintained in the CalCentral application DB.
#   * OEC :
#       - Still manually configured for now.

module Berkeley
  class Terms
    include ActiveAttr::Model, ClassLogger, DatedFeed
    extend Cache::Cacheable

    # The term shown in the My Classes widget & highlighted in the top Academics page.
    attr_reader :current
    # The term officially in progress. The academic calendar has gaps, and so this will sometimes be nil.
    attr_reader :running
    # The next term (after the current one).
    attr_reader :next
    # The next term after the next term. This will often be nil but is particularly useful
    # during Spring terms, when most instructors and most enrolled students will have more
    # interest in the Fall schedule than in Summer classes.
    attr_reader :future
    # The previous term (before the current one).
    attr_reader :previous
    # The previous term immediately after its official end, while final
    # grades are being posted.
    attr_reader :grading_in_progress
    # How far back do we look for enrollments, transcripts, & teaching assignments?
    attr_reader :oldest
    # Full list of terms in DB.
    attr_reader :campus

    def self.fetch(options = {})
      options.reverse_merge!(fake_now: Settings.terms.fake_now, oldest: Settings.terms.oldest)
      fetch_from_cache(nil, options[:force]) do
        Terms.new(options)
      end
    end

    def initialize(options)
      terms = {}
      future_terms = []
      current_date = options[:fake_now] || DateTime.now
      @oldest = options[:oldest]
      db_terms = CampusOracle::Queries.terms
      # Do initial term parsing.
      db_terms.each do |db_term|
        term = Term.new(db_term)
        terms[term.slug] = term
        if term.start > current_date
          future_terms.push term
        elsif term.end >= current_date
          @running = term
        else
          @previous ||= term
          @grading_in_progress ||= term if term.grades_entered >= current_date
        end
        break if term.slug == @oldest
      end
      @current = @running || future_terms.pop
      if (@next = future_terms.pop)
        if (@future = future_terms.pop)
          unless future_terms.empty?
            logger.info("Found more than two future terms: #{future_terms.map(&:slug).join(', ')}")
            future_terms.each {|t| terms.delete(t.slug)}
          end
        end
      end
      @campus = terms
    end

  end
end
