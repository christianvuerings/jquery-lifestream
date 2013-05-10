class UserApiController < ApplicationController

  extend Calcentral::Cacheable

  def self.expire(id = nil)
    # no-op; this class uses the cache only to reduce the number of writes to UserVisit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def mystatus
    logger.debug "mystatus for uid '#{session[:user_id]}'"
    if session[:user_id]
      # wrap UserVisit.record_session inside a cache lookup so that we have to write UserVisit records less often.
      self.class.fetch_from_cache session[:user_id] do
        UserVisit.record session[:user_id]
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
    logger.debug "#{self.class.name} recording first login for #{session[:user_id]}"
    UserApi.new(session[:user_id]).record_first_login
    render :nothing => true, :status => 204
  end

  def delete
    if session[:user_id]
      logger.debug "#{self.class.name} removing user #{session[:user_id]}"
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
