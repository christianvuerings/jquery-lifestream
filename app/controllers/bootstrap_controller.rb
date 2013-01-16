class BootstrapController < ApplicationController
  def index
    @server_settings = ServerRuntime.get_settings
  end
end
