class MyPlaylistsController < ApplicationController

  def get_playlists
    if session[:user_id]
      render :json => Webcasts::Playlists.new({:playlist_title => params[:playlist_title]}).get
    else
      render :json => {}.to_json
    end
  end

end
