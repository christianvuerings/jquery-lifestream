class RefreshLoggingController < ApplicationController
  include ClassLogger

  respond_to :json

  def refresh_logging
    # Only super-users are allowed to change log levels in production.
    if Rails.env.production? && !UserAuth.is_superuser?(session[:user_id])
      return render :nothing => true, :status => 401
    end

    response = CalcentralLogging.refresh_logging_level
    if response.blank?
      return render :nothing => true, :status => 304
    else
      return render :json => response.to_json, :status => 200
    end
  end
end
