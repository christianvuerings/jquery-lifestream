class RoutesListController < ApplicationController
  extend Cache::Cacheable

  respond_to :json

  def smoke_test_routes
    authorize(current_user, :can_administrate?)
    respond_with({routes: get_smoke_test_routes})
  end

  private

  def get_smoke_test_routes
    %w(
      /api/academics/canvas/external_tools
      /api/academics/canvas/user_can_create_course_site
      /api/blog
      /api/my/academics
      /api/my/activities
      /api/my/am_i_logged_in
      /api/my/badges
      /api/my/cal1card
      /api/my/campuslinks
      /api/my/classes
      /api/my/finaid
      /api/my/financials
      /api/my/groups
      /api/my/photo
      /api/my/status
      /api/my/tasks
      /api/my/up_next
      /api/my/updated_feeds
      /api/ping
      /api/server_info
      /api/stats
      /api/tools/styles
    )
  end
end
