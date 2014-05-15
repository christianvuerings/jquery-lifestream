class MediacastsController < ApplicationController

  before_filter :api_authenticate

  def get_media
    render :json => Mediacasts::CourseMedia.new(
      params[:year], params[:term_code], params[:dept], params[:catalog_id]
    ).get_feed
  end

end
