class RemoveYhlAuth < ActiveRecord::Migration
  def up
    Rails.logger.info "Removing (#{uid}) as a superuser"
    User::Auth.where(:uid => uid).delete_all
  end

  def down
  end

  private

  def uid
    '192517'
  end
end
