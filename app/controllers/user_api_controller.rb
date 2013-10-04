class UserApiController < ApplicationController

  extend Calcentral::Cacheable

  def self.expire(id = nil)
    # no-op; this class uses the cache only to reduce the number of writes to UserVisit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def am_i_logged_in
    response.headers["Cache-Control"] = "no-cache, no-store, private, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "-1"
    render :json => {
      :am_i_logged_in => !!session[:user_id]
    }.to_json
  end

  def mystatus
    ActiveRecordHelper.clear_stale_connections
    if session[:user_id]
      # wrap UserVisit.record_session inside a cache lookup so that we have to write UserVisit records less often.
      self.class.fetch_from_cache session[:user_id] do
        UserVisit.record session[:user_id]
        true
      end
      user_data = UserApi.new(session[:user_id]).get_feed
      render :json => {
          :is_basic_auth_enabled => Settings.developer_auth.enabled,
          :is_logged_in => true,
          :features => Settings.features.marshal_dump,
          :acting_as_uid => acting_as_uid
      }.merge!(user_data).to_json
    else
      render :json => {
          :is_basic_auth_enabled => Settings.developer_auth.enabled,
          :is_logged_in => false,
          :features => Settings.features.marshal_dump
      }.to_json
    end
  end

  def record_first_login
    UserApi.new(session[:user_id]).record_first_login
    render :nothing => true, :status => 204
  end

  def delete
    if session[:user_id]
      UserApi.delete(session[:user_id])
    end
    render :nothing => true, :status => 204
  end

  private

  def acting_as_uid
    if session[:original_user_id] && session[:user_id]
      return session[:original_user_id]
    else
      return false
    end
  end

end
