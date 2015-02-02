class BootstrapController < ApplicationController
  include ActiveRecordHelper
  before_filter :get_settings, :initialize_calcentral_config
  before_filter :check_lti_only
  before_filter :check_databases_alive, :warmup_live_updates
  layout false

  # Always redirect to public/index.html and let the front-end handle the routes
  def index
    render "public/index.html"
  end

  # CalCentral cannot fully trust a user session which was initiated via an LTI embedded app,
  # since it may reflect "masquerading" by a Canvas admin. However, most users who visit
  # bCourses before visiting CalCentral are not masquerading. This filter gives them a
  # chance to become fully authenticated on the browser's initial visit to a CalCentral page.
  # If the user's CAS login state is still active, no visible redirect will occur.
  def check_lti_only
    if session[:lti_authenticated_only]
      authenticate(true)
    end
  end

  private

  def check_databases_alive
    # so that an error gets thrown if postgres is dead.
    if !User::Data.database_alive?
      raise "CalCentral database is currently unavailable"
    end
    # so an error gets thrown if Oracle is dead.
    if !CampusOracle::Queries.database_alive?
      raise "Campus database is currently unavailable"
    end
  end

  def warmup_live_updates
    LiveUpdatesWarmer.warmup_request session[:user_id] if session[:user_id]
  end

end
