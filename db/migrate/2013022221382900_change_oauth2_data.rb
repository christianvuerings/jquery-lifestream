class ChangeOauth2Data < ActiveRecord::Migration
  def up
    add_column "oauth2_data", :app_data, :text
  end

  def down
    rename_column "oauth2_data", :app_data, :app_data_201322221382900
  end
end
