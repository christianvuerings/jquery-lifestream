class RefreshLoggingController < ApplicationController
  include ClassLogger

  respond_to :json

  def refresh_logging
    authorize(current_user, :can_refresh_log_settings?)
    response = CalcentralLogging.refresh_logging_level
    if response.blank?
      return render :nothing => true, :status => 304
    else
      return render :json => response.to_json, :status => 200
    end
  end
end
