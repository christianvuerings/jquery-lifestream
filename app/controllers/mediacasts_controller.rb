class MediacastsController < ApplicationController

  before_filter :api_authenticate

  # GET /api/media/:year/:term_code/:dept/:catalog_id
  def get_media
    render :json => Webcast::CourseMedia.new(
      params['year'], params['term_code'], params['dept'], params['catalog_id']
    ).get_feed
  end

end
