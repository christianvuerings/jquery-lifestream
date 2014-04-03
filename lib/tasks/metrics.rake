namespace :metrics do

  desc 'Count up students who have logged in '
  task :students => :environment do
    uids = []
    User::Data.find_each do |user|
      uids << user.uid.to_i
    end

    sql = <<-SQL
      select count(ldap_uid) AS students
      from calcentral_person_info_vw
      where ldap_uid IN ( #{uids.join(', ')})
        and affiliations LIKE '%STUDENT-TYPE%'
    SQL
    count=CampusOracle::Queries.connection.select_one(sql)

    Rails.logger.warn "Total user count is #{uids.length}"
    Rails.logger.warn "Student count is #{count["students"]}"

  end

end
