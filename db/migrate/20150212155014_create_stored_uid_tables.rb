class CreateStoredUidTables < ActiveRecord::Migration
  def change
    create_table :saved_uids do |t|
      t.string :owner_uid
      t.string :stored_uid
      t.timestamps
    end

    create_table :recent_uids do |t|
      t.string :owner_uid
      t.string :stored_uid
      t.timestamps
    end
  end
end
