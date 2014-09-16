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
        User::Visit.record session[:user_id] if current_user.directly_authenticated?
        true
      end
      status.merge!({
        :isBasicAuthEnabled => Settings.developer_auth.enabled,
        :isLoggedIn => true,
        :features => Settings.features.marshal_dump,
        # Note the misleading field name.
        :actingAsUid => (current_user.directly_authenticated? ? false : current_user.real_user_id),
        :youtubeSplashId => Settings.youtube_splash_id
      })
      status.merge!(User::Api.from_session(session).get_feed)
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
    User::Api.from_session(session).record_first_login if current_user.directly_authenticated?
    render :nothing => true, :status => 204
  end

  def delete
    if session[:user_id] && current_user.directly_authenticated?
      User::Api.delete(session[:user_id])
      render :nothing => true, :status => 204
    else
      render :nothing => true, :status => 403
    end
  end

  def calendar_opt_in
    expire_current_user
    if session[:user_id] && current_user.directly_authenticated?
      Calendar::User.first_or_create({uid: session[:user_id]})
      render :nothing => true, :status => 204
    else
      render :nothing => true, :status => 403
    end
  end

  def calendar_opt_out
    expire_current_user
    if session[:user_id] && current_user.directly_authenticated?
      Calendar::User.delete_all({uid: session[:user_id]})
      render :nothing => true, :status => 204
    else
      render :nothing => true, :status => 403
    end
  end

end
