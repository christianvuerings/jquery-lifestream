class UpdateEliUid < ActiveRecord::Migration
  def up
    eli = User::Auth.find(:first, :conditions => {:uid => "3222279"})
    if eli
      eli.update_attributes!(:uid => 322279)
    end
  end

  def down
    # We never want to revert the bad uid error
  end
end
