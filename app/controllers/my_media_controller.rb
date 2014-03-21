class MyMediaController < ApplicationController

  def get_media
    if session[:user_id]
      render :json => Mediacasts::MyMedia.new(:playlist_title => params[:playlist_title]).get_media_as_json
    else
      render :json => {}.to_json
    end
  end

end
