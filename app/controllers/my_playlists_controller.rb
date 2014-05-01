class MyPlaylistsController < ApplicationController

  before_filter :api_authenticate

  def get_playlists
    render :json => Mediacasts::Playlists.new({:playlist_title => params[:playlist_title]}).get
  end

end
