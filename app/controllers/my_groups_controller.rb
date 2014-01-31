class MyGroupsController < ApplicationController

  def get_feed
    if session[:user_id]
      render :json => MyGroups::Merged.new(session[:user_id]).get_feed_as_json
    else
      render :json => {}.to_json
    end
  end

end
