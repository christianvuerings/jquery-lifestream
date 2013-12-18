class MyResearchGroupsController < ApplicationController

  def get_feed
    if session[:user_id]
      render :json => MyResearchGroups.new(session[:user_id]).get_feed
    else
      render :json => {}.to_json
    end
  end

end
