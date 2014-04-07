namespace :metrics do

  desc 'Count up students who have logged in '
  task :students => :environment do
    total_uids_count = 0
    total_students_count = 0

    User::Data.find_in_batches(batch_size: 500) do |group|
      uids = []
      group.each do |user|
        uids << user.uid.to_i
      end

      sql = <<-SQL
      select count(ldap_uid) AS students
      from calcentral_person_info_vw
      where ldap_uid IN ( #{uids.join(', ')})
        and affiliations LIKE '%STUDENT-TYPE%'
      SQL
      count=CampusOracle::Queries.connection.select_one(sql)
      total_uids_count += uids.length
      total_students_count += count["students"].to_i
    end

    Rails.logger.warn "Total user count is #{total_uids_count}"
    Rails.logger.warn "Student count is #{total_students_count}"

  end

end
