class MyMediaController < ApplicationController

  before_filter :api_authenticate

  def get_media
    render :json => Mediacasts::MyMedia.new(:playlist_title => params[:playlist_title]).get_media_as_json
  end

end
