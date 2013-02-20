class ChangeUserDataSchema < ActiveRecord::Migration
  def up
    change_table :user_data do |t|
      t.column :is_test_user, :boolean, :null => false, :default => false
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

    test_users = UserData.all(:conditions => ["uid IN (?)", test_user_ids] )
    test_users.each do |entry|
      Rails.logger.debug "Flagging #{entry.uid} as a test user"
      entry.is_test_user = true
      entry.save
    end
  end

  def down
    change_table :user_data do |t|
      t.remove :is_test_user
    end
  end
end
