class CreateCanvasSynchronizationTable < ActiveRecord::Migration
  def change
    create_table :canvas_synchronization do |t|
      t.datetime :last_guest_user_sync
    end
  end
end
