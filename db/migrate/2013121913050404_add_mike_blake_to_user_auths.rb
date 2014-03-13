class AddMikeBlakeToUserAuths < ActiveRecord::Migration
  def up
    Rails.logger.info "Flagging Mike Blake(#{uid}) as a superuser"
    User::Auth.new_or_update_superuser! uid
  end

  def down
    User::Auth.where(:uid => uid).delete_all
  end

  private

  def uid
    '1051203'
  end

end
