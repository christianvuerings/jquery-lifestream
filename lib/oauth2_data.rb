class Oauth2Data < ActiveRecord::Base
  attr_accessible :app_id, :expiration_time, :refresh_token, :access_token, :uid

  def self.access_granted?(user_id, app_id)
    get_access_token(user_id, app_id) != nil
  end

  def self.get_access_token(user_id, app_id)
    oauth2_data = Oauth2Data.where(uid: user_id, app_id: app_id).first
    oauth2_data && oauth2_data.access_token
  end

end
