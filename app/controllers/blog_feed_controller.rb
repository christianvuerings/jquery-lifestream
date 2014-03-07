class BlogFeedController < ApplicationController

  caches_action(:get_latest_release_notes, :expires_in => ReleaseNotes.expires_in)

  def get_latest_release_notes
    render :json => ReleaseNotes.new.get_latest_release_notes
  end

end
