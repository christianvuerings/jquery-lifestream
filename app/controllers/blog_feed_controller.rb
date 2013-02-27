class BlogFeedController < ApplicationController

  def get_latest_release_notes
    render :json => BlogFeed.new.get_latest_release_notes
  end

end
