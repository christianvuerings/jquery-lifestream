class ServerRuntimeController < ApplicationController

  def get_info
    render :json => ServerRuntime.get_settings.to_json
  end

end
