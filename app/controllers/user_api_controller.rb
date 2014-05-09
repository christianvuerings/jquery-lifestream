class UserApiController < ApplicationController

  extend Cache::Cacheable

  def self.expire(id = nil)
    # no-op; this class uses the cache only to reduce the number of writes to User::Visit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def am_i_logged_in
    response.headers["Cache-Control"] = "no-cache, no-store, private, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "-1"
    render :json => {
      :amILoggedIn => !!session[:user_id]
    }.to_json
  end

  def mystatus
    ActiveRecordHelper.clear_stale_connections
    status = {}

    if session[:user_id]
      # wrap User::Visit.record_session inside a cache lookup so that we have to write User::Visit records less often.
      self.class.fetch_from_cache session[:user_id] do
        User::Visit.record session[:user_id] unless acting_as?
        true
      end
      status.merge!({
        :isBasicAuthEnabled => Settings.developer_auth.enabled,
        :isLoggedIn => true,
        :features => Settings.features.marshal_dump,
        :actingAsUid => acting_as_uid,
        :youtubeSplashId => Settings.youtube_splash_id
      })
      status.merge!(User::Api.new(session[:user_id]).get_feed)
    else
      status.merge!({
        :isBasicAuthEnabled => Settings.developer_auth.enabled,
        :isLoggedIn => false,
        :features => Settings.features.marshal_dump,
        :youtubeSplashId => Settings.youtube_splash_id
      })
    end
    render :json => status.to_json
  end

  def record_first_login
    User::Api.new(session[:user_id]).record_first_login unless acting_as?
    render :nothing => true, :status => 204
  end

  def delete
    if session[:user_id]
      User::Api.delete(session[:user_id]) unless acting_as?
    end
    render :nothing => true, :status => 204
  end

  private

  def acting_as?
    session[:original_user_id] && (session[:user_id] != session[:original_user_id])
  end

  def acting_as_uid
    if session[:original_user_id] && session[:user_id]
      return session[:original_user_id]
    else
      return false
    end
  end

end
