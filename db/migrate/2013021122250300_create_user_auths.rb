class CreateUserAuths < ActiveRecord::Migration
  def up
    create_table :user_auths do |t|
      t.string :uid, :null => false
      t.boolean :is_superuser, :null => false, :default => false
      t.boolean :active, :null => false, :default => false
      t.timestamps :modified
    end

    change_table :user_auths do |t|
      t.index [:uid], :unique => true
    end

    # Seeding super users, test users.
    super_users = %w(192517 323487 191779 238382 208861 675750 3222279 2040 904715 211159 978966)
    super_users.each do |uid|
      Rails.logger.info "Flagging #{uid} as a superuser"
      UserAuth.new_or_update_superuser! uid
    end
  end

  def down
    drop_table :user_auths
  end
end
