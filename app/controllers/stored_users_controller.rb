class StoredUsersController < ApplicationController
  before_filter :authenticate
  before_filter :numeric_uid?, except: [:get]
  respond_to :json

  def get
    authorize(current_user, :can_view_as?)
    users_found = User::StoredUsers.get(current_user.real_user_id)
    render json: { users: users_found }.to_json
  end

  def store_saved_uid
    response = User::StoredUsers.store_saved_uid(current_user.real_user_id, params['uid'])
    render json: response.to_json
  end

  def delete_saved_uid
    response = User::StoredUsers.delete_saved_uid(current_user.real_user_id, params['uid'])
    render json: response.to_json
  end

  private

  def error_response
   result = { success: false, message: 'Please provide a numeric UID.' }
    respond_with(result) do |format|
      format.json { render json: result.to_json, status: :bad_request }
    end
  end

  def numeric_uid?
    begin
      Integer(params['uid'], 10)
    rescue ArgumentError
      error_response
    end
  end

end
