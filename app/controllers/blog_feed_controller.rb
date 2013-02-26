class BlogFeedController < ApplicationController

  def get_release_notes
    render :json => BlogFeed.new.get_release_notes
  end

end
