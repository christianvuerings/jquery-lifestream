class MyRegBlocksController < ApplicationController

  def get_feed
    if session[:user_id]
      render :json => MyRegBlocks.new(session[:user_id]).get_feed.to_json
    else
      render :json => {}.to_json
    end
  end

end
