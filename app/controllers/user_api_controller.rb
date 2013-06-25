class UserApiController < ApplicationController

  extend Calcentral::Cacheable

  def self.expire(id = nil)
    # no-op; this class uses the cache only to reduce the number of writes to UserVisit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def mystatus
    Rails.cache.fetch(
      "flush_stale_connections_#{ServerRuntime.get_settings["hostname"]}",
      :expires_in => Settings.cache.stale_connection_flush_interval) {
      ActiveRecord::Base.connection_pool.clear_stale_cached_connections!
      true
    }
    if session[:user_id]
      # wrap UserVisit.record_session inside a cache lookup so that we have to write UserVisit records less often.
      self.class.fetch_from_cache session[:user_id] do
        UserVisit.record session[:user_id]
        true
      end
      user_data = UserApi.new(session[:user_id]).get_feed
      render :json => {
          :is_logged_in => true,
          :features => Settings.features.marshal_dump,
          :is_acting_as => is_acting_as_someone_else?
      }.merge!(user_data).to_json
    else
      render :json => {
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

  def is_acting_as_someone_else?
    if session[:original_user_id] && session[:user_id]
      return session[:original_user_id] != session[:user_id]
    else
      return false
    end
  end

end
