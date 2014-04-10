class RoutesListController < ApplicationController
  extend Cache::Cacheable

  respond_to :json

  def smoke_test_routes
    authorize(current_user, :can_administrate?)
    test_routes = self.class.fetch_from_cache do
      get_smoke_test_routes
    end
    respond_with({routes: test_routes})
  end

  private

  def get_smoke_test_routes
    # This gets all the GET routes matching /api/...
    test_routes = Rails.application.routes.routes.map do |r|
      if (r.constraints.present? && !(r.constraints[:request_method] =~ 'POST').nil?)
        ''
      elsif r.path.spec.to_s.starts_with?('/api/')
        r.path.spec.to_s.chomp('(.:format)')
      else
        ''
      end
    end
    blacklist = %w(
        /api/my/campuslinks/expire
        /api/my/textbooks_details
        /api/clear_cache
        /api/canvas/request_authorization
        /api/google/request_authorization
        /api/google/handle_callback
        /api/academics/rosters/canvas/:canvas_course_id
        /api/academics/canvas/course_add_user/course_sections
        /api/academics/canvas/course_add_user/search_users
        /api/academics/canvas/course_provision_as/:instructor_id
        /api/academics/canvas/course_provision/create
        /api/academics/canvas/course_provision/status
        /api/academics/canvas/course_user_profile
        /api/academics/rosters/campus/:campus_course_id
        /api/search_users/:id
      )
    test_routes.reject {|x| x.empty? || blacklist.include?(x)}
  end
end
