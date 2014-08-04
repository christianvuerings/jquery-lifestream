class SeedCanvasSynchronization < ActiveRecord::Migration
  def up
    Canvas::Synchronization.create(:last_guest_user_sync => 1.weeks.ago.utc)
  end

  def down
    Canvas::Synchronization.delete_all
  end
end
