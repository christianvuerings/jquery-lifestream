class MyTasksController < ApplicationController

  def get_feed
    if session[:user_id]
      dummyjson = File.read(Rails.root.join('public/dummy/tasks.json'))
      render :json => dummyjson
    else
      render :json => {}.to_json
    end
  end

end