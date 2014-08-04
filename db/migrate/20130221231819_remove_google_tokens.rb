class RemoveGoogleTokens < ActiveRecord::Migration
  def up
    say_with_time "Moving old Google tokens to Google-2013022123181900" do
      User::Oauth2Data.where(:app_id => "Google").each do |entry|
        entry.update_attribute :app_id, "Google-2013022123181900"
      end
    end
  end

  def down
    say_with_time "Removing current Google tokens and restoring tokens from Google-2013022123181900" do
      User::Oauth2Data.delete_all(:app_id => "Google")
      User::Oauth2Data.where(:app_id => "Google-2013022123181900").each do |entry|
        entry.update_attribute :app_id, "Google"
      end
    end
  end
end
