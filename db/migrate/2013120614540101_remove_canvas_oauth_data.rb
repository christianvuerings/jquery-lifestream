class RemoveCanvasOauthData < ActiveRecord::Migration

  def up
    Rails.logger.warn "Removing Canvas OAuth2 rows"
    User::Oauth2Data.where(:app_id => Canvas::Proxy::APP_ID).delete_all
  end

  def down
    Rails.logger.warn "This migration is not reversible"
  end

end
