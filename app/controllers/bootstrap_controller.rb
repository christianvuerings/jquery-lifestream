class BootstrapController < ApplicationController
  def index
    @server_settings = ServerRuntime.get_settings
    @release_notes = BlogFeed.new.get_release_notes
  end
end
