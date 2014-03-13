class DarleneSuperUser < ActiveRecord::Migration
  def up
    Rails.logger.info "Flagging Darlene Kawase (#{uid}) as a superuser"
    User::Auth.new_or_update_superuser! uid
  end

  def down
    User::Auth.where(:uid => uid).delete_all
  end

  private

  def uid
    '53791'
  end

end
