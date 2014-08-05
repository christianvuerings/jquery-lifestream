class DropOldTokens < ActiveRecord::Migration
  def up
    target_tokens = %w(Google-2013040911200984 Google-2013022123412000
      Google-2013022123181900 Canvas-20130423 Google-2013040912314334)
    target_tokens.each do |token_id|
      say "Removing app_id: #{token_id} tokens"
      User::Oauth2Data.where(:app_id => token_id).delete_all
    end
  end

  def down
  end
end
