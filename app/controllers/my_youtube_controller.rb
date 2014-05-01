class MyYoutubeController < ApplicationController

  before_filter :api_authenticate

  def get_videos
    render :json => Mediacasts::Youtube.new({:playlist_id => params[:playlist_id]}).get
  end

end
