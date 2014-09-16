class DropIsTestUserAuth < ActiveRecord::Migration

  def up
    remove_column "user_auths", :is_test_user
  end

  def down
    change_table :user_auths do |t|
      t.boolean :is_test_user, :null => false, :default => false
    end
  end

end
