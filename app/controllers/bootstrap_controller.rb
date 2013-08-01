class BootstrapController < ApplicationController
  include ActiveRecordHelper
  before_filter :check_databases_alive
  layout 'application'
  caches_action :index, :layout => false

  def index
    gon.application_version = ServerRuntime.get_settings["versions"]["application"]
    gon.client_hostname = ServerRuntime.get_settings["hostname"]
    gon.google_analytics_id = Settings.google_analytics_id
    gon.sentry_url = Settings.sentry_url
    respond_to :html
  end

  private

  def check_databases_alive
    # so that an error gets thrown if postgres is dead.
    if !UserData.database_alive?
      raise "CalCentral database is currently unavailable"
    end
    # so an error gets thrown if Oracle is dead.
    if !CampusData.database_alive?
      raise "Campus database is currently unavailable"
    end
  end

end
