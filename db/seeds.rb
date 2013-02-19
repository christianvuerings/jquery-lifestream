# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# Seeding super users, test users.
if (ActiveRecord::Migrator.current_version >= 2013021122250300)
  super_users = %w(192517 323487 191779 238382 208861 675750 3222279 2040 904715 211159 978966)
  super_users.each do |uid|
    Rails.logger.info "Flagging #{uid} as a superuser"
    UserAuth.new_or_update_superuser! uid
  end

  act_as_users = [
    {:uid => '11002820', :acting_as_uid => '61889'} # Let Tammi act as oski.
  ]
  act_as_users.each do |entry|
    Rails.logger.info "Granting #{entry[:uid]} to act as #{entry[:acting_as_uid]}"
    UserAuth.new_or_update_act_as!(entry[:uid], entry[:acting_as_uid])
  end
end

# Flagging test users.
if (ActiveRecord::Migrator.current_version >= 2013021320072300)
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
