class ChangeUserDataSchema < ActiveRecord::Migration
  def up
    change_table :user_data do |t|
      t.column :is_test_user, :boolean, :null => false, :default => false
    end

  end

  def down
    change_table :user_data do |t|
      t.remove :is_test_user
    end
  end
end
