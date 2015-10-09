class RemoveObsoleteOauthOec < ActiveRecord::Migration
  def change
    uid = '12004714'
    if Settings.oec.google.uid == uid
      Rails.logger.warn "Do NOT delete oauth2_data where uid='#{uid}' because, according to YAML, #{uid} is still used. "
    else
      User::Oauth2Data.where(:uid => uid).delete_all
    end
  end
end
