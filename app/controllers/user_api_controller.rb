class UserApiController < ApplicationController

  def mystatus
    logger.debug "mystatus for uid '#{session[:user_id]}'"
    if session[:user_id]
      user_data = UserApi.new(session[:user_id]).get_feed
      render :json => {
          :is_logged_in => true
      }.merge!(user_data).to_json
    else
      render :json => {
          :is_logged_in => false
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
    redirect_to "/logout"
  end

end
