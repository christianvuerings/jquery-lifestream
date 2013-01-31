class DropWidgetData < ActiveRecord::Migration

  def up
    drop_table :widget_data
  end

  def down
    create_table :widget_data do |t|
      t.string :uid
      t.string :widget_id
      t.text :data
      t.timestamps
    end

  end

end
