module Canvas
  class SiteCreation
    extend Cache::Cacheable

    def initialize(options = {})
      @uid = options[:uid]
    end

    def authorizations
      policy = AuthenticationState.new(user_id: @uid).policy
      {
        :authorizations => {
          :canCreateCourseSite => policy.can_create_canvas_course_site?,
          :canCreateProjectSite => policy.can_create_canvas_project_site?,
        }
      }
    end
  end
end
