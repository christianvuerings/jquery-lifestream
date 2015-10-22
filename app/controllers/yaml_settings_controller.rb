class YamlSettingsController < ApplicationController
  include ClassLogger

  respond_to :json

  def reload
    authorize(current_user, :can_clear_cache?)
    begin
      is_success = CalcentralConfig.reload_settings
      # Give user a snippet of the settings
      json = { reloaded: is_success }
      json[:snippet] = { features: Settings.features.marshal_dump } unless !is_success || Settings.features.nil?
      # 400 code: Bad request, impossible to satisfy
      render :json => json, :status => (is_success ? 200 : 400)
    rescue => e
      logger.fatal 'Failed to reload YAML file. PLEASE consider a server restart because the state of the system is unknown.'
      logger.fatal "#{e.message}\n#{e.backtrace.join "\n\t"}"
      render :json => {reloaded: false}, :status => 500
    end
  end

end
