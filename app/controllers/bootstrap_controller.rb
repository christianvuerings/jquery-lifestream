class BootstrapController < ApplicationController
  include ActiveRecordHelper

  def index
    # so that an error gets thrown if postgres is dead.
    use_pooled_connection {
      UserData.find_by_sql("select 1").first
    }
    CampusData.check_alive # so an error gets thrown if Oracle is dead.
    @server_settings = ServerRuntime.get_settings
  end
end
