class CreateUserAuths < ActiveRecord::Migration
  def up
    create_table :user_auths do |t|
      t.string :uid, :null => false
      t.boolean :is_superuser, :null => false, :default => false
      t.boolean :active, :null => false, :default => false
      t.timestamps :modified
    end

    change_table :user_auths do |t|
      t.index [:uid], :unique => true
    end
  end

  def down
    drop_table :user_auths
  end
end
