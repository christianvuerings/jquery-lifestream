class BlogFeedController < ApplicationController

  caches_action(:get_latest_release_notes, :expires_in => BlogFeedProxy.expires_in)

  def get_latest_release_notes
    render :json => BlogFeedProxy.new.get_latest_release_notes
  end

end
