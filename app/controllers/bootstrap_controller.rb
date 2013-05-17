class BootstrapController < ApplicationController
  include ActiveRecordHelper
  before_filter :check_databases_alive
  caches_action :index, :cache_path => :cache_path_with_hostname.to_proc
  respond_to :html

  def index
    respond_to do |t|
      t.html do
        @server_settings = ServerRuntime.get_settings
      end
    end
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

  def cache_path_with_hostname
    "#{ServerRuntime.get_settings['hostname']}/bootstrap/index"
  end
end
