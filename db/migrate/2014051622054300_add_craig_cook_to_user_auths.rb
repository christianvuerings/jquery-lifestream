class AddCraigCookToUserAuths < ActiveRecord::Migration

  def up
    Rails.logger.info "Flagging Craig Cook(#{craigs_uid}) as a superuser"
    User::Auth.new_or_update_superuser! craigs_uid
    Rails.logger.info "Removing Mike Blake(#{mikes_uid}) as a superuser"
    User::Auth.where(:uid => mikes_uid).delete_all
  end

  def down
    User::Auth.where(:uid => craigs_uid).delete_all
    User::Auth.new_or_update_superuser! mikes_uid
  end

  private

  def craigs_uid
    '1078671'
  end

  def mikes_uid
    '1051203'
  end


end
