class BootstrapController < ApplicationController

  def index
    UserData.find_by_sql("select 1").first # so that an error gets thrown if postgres is dead.
    CampusData.check_alive # so an error gets thrown if Oracle is dead.
    @server_settings = ServerRuntime.get_settings
    @release_notes = BlogFeed.new.get_release_notes
  end
end
