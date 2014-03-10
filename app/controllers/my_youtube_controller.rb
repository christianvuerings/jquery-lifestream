class MyYoutubeController < ApplicationController

  def get_videos
    if session[:user_id]
      render :json => Youtube.new({:playlist_id => params[:playlist_id]}).get
    else
      render :json => {}.to_json
    end
  end

end
