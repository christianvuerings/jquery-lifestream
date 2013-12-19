class MyVideosController < ApplicationController

  def get_videos
    if session[:user_id]
      render :json => MyVideos.new(:playlist_title => params[:playlist_title]).get_videos_as_json
    else
      render :json => {}.to_json
    end
  end

end
