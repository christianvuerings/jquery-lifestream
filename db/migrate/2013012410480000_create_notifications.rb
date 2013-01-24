class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.string :uid
      t.text :data
      t.timestamps
    end

    change_table :notifications do |t|
      t.index :uid
    end
  end

  def down
    drop_table :notifications
  end

end