module Canvas
  class CurrentTeacher
    extend Cache::Cacheable

    def initialize(uid)
      @uid = uid
    end

    def user_currently_teaching?
      self.class.fetch_from_cache @uid do
        current_terms = Canvas::Terms.current_terms
        CampusOracle::Queries.has_instructor_history?(@uid, current_terms)
      end
    end

  end
end
