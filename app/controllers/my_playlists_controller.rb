class MyPlaylistsController < ApplicationController

  def get_playlists
    if session[:user_id]
      render :json => MyPlaylists.new(:playlist_title => params[:playlist_title]).get_playlists_as_json
    else
      render :json => {}.to_json
    end
  end

end
