class AddMikeBlakeToUserAuths < ActiveRecord::Migration
  def up
    Rails.logger.info "Flagging Mike Blake(#{uid}) as a superuser"
    UserAuth.new_or_update_superuser! uid
  end

  def down
    UserAuth.where(:uid => uid).delete_all
  end

  private

  def uid
    '1051203'
  end

end
