class AddDougAuToUserAuths < ActiveRecord::Migration
  def up
    Rails.logger.info "Flagging Doug Au(#{uid}) as a superuser"
    User::UserAuth.new_or_update_superuser! uid
  end

  def down
    User::UserAuth.where(:uid => uid).delete_all
  end

  private

  def uid
    '12492'
  end

end
