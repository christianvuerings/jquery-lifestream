class BootstrapController < ApplicationController
  include ActiveRecordHelper
  before_filter :get_settings, :initialize_calcentral_config
  before_filter :check_databases_alive, :warmup_live_updates
  layout 'application'
  caches_action :index, :layout => false

  def index
    respond_to :html
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
