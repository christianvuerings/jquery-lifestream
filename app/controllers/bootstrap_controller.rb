class BootstrapController < ApplicationController
  include ActiveRecordHelper
  before_filter :get_settings, :initialize_calcentral_config
  before_filter :check_lti_only
  before_filter :check_databases_alive, :warmup_live_updates, :check_cache_clear_flag
  layout false

  # View code is public/index-main.html (compiled by gulp build).
  # We don't want to serve index-main statically because that would skip the check_databases_alive and
  # check_reauthentication code.
  def index
    render 'public/index-main.html'
  end

  # CalCentral cannot fully trust a user session which was initiated via an LTI embedded app,
  # since it may reflect "masquerading" by a Canvas admin. However, most users who visit
  # bCourses before visiting CalCentral are not masquerading. This filter gives them a
  # chance to become fully authenticated on the browser's initial visit to a CalCentral page.
  # If the user's CAS login state is still active, no visible redirect will occur.
  def check_lti_only
    if session['lti_authenticated_only']
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
    LiveUpdatesWarmer.warmup_request session['user_id'] if session['user_id']
  end

  def check_cache_clear_flag
    # Sent from Campus Solutions Fluid UI when returning to CalCentral from
    # a Fluid activity that may have changed some data.
    flag = params['ucUpdateCache']
    case flag
      when 'finaid'
        CampusSolutions::FinancialAidExpiry.expire current_user.user_id
      when 'profile'
        CampusSolutions::PersonDataExpiry.expire current_user.user_id
      else
        # no-op
    end
  end

end
