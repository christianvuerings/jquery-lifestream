class MyTasksController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render :json => MyTasks::Merged.from_session(session).get_feed_as_json
  end

  def self.define_filtered_passthrough(endpoint)
    define_method endpoint do
      begin
        raise ArgumentError if UserSpecificModel.session_indirectly_authenticated?(session)
        my_tasks_model = MyTasks::Merged.from_session(session)
        render :json => my_tasks_model.send(endpoint, request.request_parameters).to_json
      rescue ArgumentError => e
        return render :json => {error: "Invalid Arguments", message: e.message}.to_json, :status => 400
      end
    end
  end

  define_filtered_passthrough :update_task
  define_filtered_passthrough :insert_task
  define_filtered_passthrough :clear_completed_tasks
  define_filtered_passthrough :delete_task

end
