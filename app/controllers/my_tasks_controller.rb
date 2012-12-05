class MyTasksController < ApplicationController

  def get_feed
    if session[:user_id]
      my_tasks_model = MyTasks.new session[:user_id]
      render :json => my_tasks_model.get_feed.to_json
    else
      render :json => {}.to_json
    end
  end

end
