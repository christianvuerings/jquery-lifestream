class CreateCanvasSiteMailingLists < ActiveRecord::Migration
  def change
    create_table :canvas_site_mailing_lists do |t|
      t.string :canvas_site_id
      t.string :list_name
      t.string :state
      t.timestamp :populated_at

      t.timestamps
    end
    add_index(:canvas_site_mailing_lists, :canvas_site_id, unique: true)
  end

end
