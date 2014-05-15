module Canvas
  class PublicAuthorizer
    extend Cache::Cacheable

    def initialize(canvas_user_id)
      @canvas_user_id = canvas_user_id
    end

    def user_currently_teaching?
      self.class.fetch_from_cache @canvas_user_id do
        return false unless campus_user_id
        current_terms = Canvas::Proxy.canvas_current_terms
        CampusOracle::Queries.has_instructor_history?(campus_user_id, current_terms)
      end
    end

    private

    def campus_user_id
      @uid ||= Canvas::UserProfile.new(:canvas_user_id => @canvas_user_id.to_s).login_id
    end

  end
end
