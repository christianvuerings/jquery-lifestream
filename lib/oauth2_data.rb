class Oauth2Data < ActiveRecord::Base
  attr_accessible :app_id, :expiration_time, :refresh_token, :access_token, :uid
end
