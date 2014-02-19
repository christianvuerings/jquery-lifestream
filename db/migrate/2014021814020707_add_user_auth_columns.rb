class AddUserAuthColumns < ActiveRecord::Migration

  def up
    change_table :user_auths do |t|
      t.boolean :is_author, :null => false, :default => false
      t.boolean :is_viewer, :null => false, :default => false
    end
  end

  def down
    remove_column "user_auths", :is_author
    remove_column "user_auths", :is_viewer
  end

end
