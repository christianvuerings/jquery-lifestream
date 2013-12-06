class RemoveCanvasOauthData < ActiveRecord::Migration

  def up
    Rails.logger.warn "Removing Canvas OAuth2 rows"
    Oauth2Data.where(:app_id => CanvasProxy::APP_ID).delete_all
  end

  def down
    Rails.logger.warn "This migration is not reversible"
  end

end
