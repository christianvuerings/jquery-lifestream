class MyTasksController < ApplicationController

  before_filter :check_authentication

  def get_feed
    render :json => MyTasks::Merged.new(session[:user_id], :original_user_id => session[:original_user_id]).get_feed.to_json
  end

  def self.define_passthrough(endpoint)
    define_method endpoint do
      begin
        my_tasks_model = MyTasks::Merged.new(session[:user_id], :original_user_id => session[:original_user_id])
        render :json => my_tasks_model.send(endpoint, request.request_parameters).to_json
      rescue ArgumentError => e
        return render :json => {error: "Invalid Arguments", message: e.message}.to_json, :status => 400
      end
    end
  end

  define_passthrough :update_task
  define_passthrough :insert_task
  define_passthrough :clear_completed_tasks
  define_passthrough :delete_task

  private
  def check_authentication
    render :json => {}.to_json unless session[:user_id]
  end

end
