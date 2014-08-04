class DropUserWhitelist < ActiveRecord::Migration
  def up
    drop_table :user_whitelists
  end

  def down
    create_table :user_whitelists do |t|
      t.string :uid
      t.timestamps
    end
    change_table :user_whitelists do |t|
      t.index [:uid], :unique => true
    end
  end
end
