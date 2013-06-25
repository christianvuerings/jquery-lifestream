class CreateUserAuths < ActiveRecord::Migration
  def up
    create_table :user_auths do |t|
      t.string :uid, :null => false
      t.boolean :is_superuser, :null => false, :default => false
      t.boolean :is_test_user, :null => false, :default => false
      t.boolean :active, :null => false, :default => false
      t.timestamps :modified
    end

    change_table :user_auths do |t|
      t.index [:uid], :unique => true
    end

    # Seeding super users
    super_users = %w(192517 323487 191779 238382 208861 675750 3222279 2040 904715 211159 978966)
    super_users.each do |uid|
      Rails.logger.info "Flagging #{uid} as a superuser"
      UserAuth.new_or_update_superuser! uid
    end

    # Flagging test users.
    test_user_ids = %w(11002820 61889)
    test_user_ids += %w(321765 321703 324731 212388 212387)
    #Injecting the universal test ids
    add_range = lambda {|id_lower, id_upper|
      test_user_ids += (id_lower..id_upper).to_a.map!{|arg| arg.to_s}
    }
    add_range.call(212372, 212378)
    add_range.call(212379, 212381)
    add_range.call(300846, 300945)
    add_range.call(212382, 212386)
    add_range.call(322587, 322590)
    add_range.call(322583, 322586)
    test_user_ids.uniq!

    test_user_ids.each do |uid|
      Rails.logger.info "Flagging #{uid} as a test user"
      UserAuth.new_or_update_test_user! uid
    end

  end

  def down
    drop_table :user_auths
  end
end
