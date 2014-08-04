class CreateUserWhitelist < ActiveRecord::Migration
  def up
    create_table :user_whitelists do |t|
      t.string :uid
      t.timestamps
    end
    change_table :user_whitelists do |t|
      t.index [:uid], :unique => true
    end
  end

  def down
    drop_table :user_whitelists
  end
end
