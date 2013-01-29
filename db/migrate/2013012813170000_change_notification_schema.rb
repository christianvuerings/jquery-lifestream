class ChangeNotificationSchema < ActiveRecord::Migration

  def up
    # drop and recreate notifications since earlier versions stored translated data, and in the future
    # we want to store only raw data.

    drop_table :notifications

    create_table :notifications do |t|
      t.string :uid
      t.text :data
      t.text :translator
      t.timestamps
    end

    change_table :notifications do |t|
      t.index :uid
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
