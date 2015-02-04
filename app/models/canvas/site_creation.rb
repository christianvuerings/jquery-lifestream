module Canvas
  class SiteCreation
    extend Cache::Cacheable

    def initialize(options = {})
      @uid = options[:uid]
    end

    def authorizations
      policy = AuthenticationState.new(user_id: @uid).policy
      {
        :can_create_course_site => policy.can_create_canvas_course_site?,
        :can_create_project_site => policy.can_create_canvas_project_site?,
      }
    end
  end
end
