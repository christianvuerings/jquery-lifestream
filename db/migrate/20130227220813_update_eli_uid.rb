class UpdateEliUid < ActiveRecord::Migration
  def up
    eli = UserAuth.find(:first, :conditions => {:uid => "3222279"})
    eli.update_attributes!(:uid => 322279)
  end

  def down
    # We never want to revert the bad uid error
  end
end
