class IsUpdatedController < ApplicationController

  # kick off a live-updates warmup, and return the last modification time and hashes of all feeds.
  def list
    if session[:user_id]
      LiveUpdatesWarmer.warmup_request session[:user_id]
      whiteboard = Cache::FeedUpdateWhiteboard.get_whiteboard session[:user_id]
      render :json => whiteboard.to_json, :status => 200
    else
      render :nothing => true, :status => 401
    end
  end

end
