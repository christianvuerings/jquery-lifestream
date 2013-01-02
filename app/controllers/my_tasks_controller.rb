class MyTasksController < ApplicationController

  before_filter :check_authentication

  def get_feed
    render :json => MyTasks.new(session[:user_id]).get_feed.to_json
  end

  def update_task
    begin
      my_tasks_model = MyTasks.new session[:user_id]
      render :json => my_tasks_model.update_task(request.request_parameters).to_json
    rescue ArgumentError => e
      return render :json => {error: "Invalid Arguments", message: e.message}.to_json, :status => 400
    end
  end

  def insert_task
    begin
      my_tasks_model = MyTasks.new session[:user_id]
      render :json => my_tasks_model.insert_task(request.request_parameters).to_json
    rescue ArgumentError => e
      return render :json => {error: "Invalid Arguments", message: e.message}.to_json, :status => 400
    end
  end

  private
  def check_authentication
    render :json => {}.to_json unless session[:user_id]
  end

end
