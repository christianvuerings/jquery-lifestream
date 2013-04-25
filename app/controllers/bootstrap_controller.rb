class BootstrapController < ApplicationController
  include ActiveRecordHelper

  def index
    # so that an error gets thrown if postgres is dead.
    if !UserData.database_alive?
      raise "CalCentral database is currently unavailable"
    end
    # so an error gets thrown if Oracle is dead.
    if !CampusData.database_alive?
      raise "Campus database is currently unavailable"
    end
    @server_settings = ServerRuntime.get_settings
  end

end
