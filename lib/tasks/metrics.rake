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

  desc 'Get a randomized list of student emails and names for marketing purposes.'
  # Run task like so on a production node:
  # RAILS_ENV=production rake metrics:student_sample N=2000
  task :student_sample => :environment do

    users = []
    User::Data.find_in_batches(batch_size: 500) do |group|
      group.each do |user|
        users << user.uid.strip.to_i if user.uid.present?
      end
    end
    users = users.shuffle

    number = ENV['N'].present? ? ENV['N'].to_i : 50
    Rails.logger.warn "Taking a random sample of #{number} UIDs"

    found = 0
    CSV.open(Rails.root.join('tmp', 'sample_emails.csv'), 'wb') do |outfile|
      users.each_slice(200) { |uids|

        # get students (grad and undergrad) who have logged in to CalCentral at least once
        statement = <<-SQL
          SELECT p.email_address, p.first_name, p.last_name
          FROM calcentral_person_info_vw p, calcentral_student_info_vw s
          WHERE p.ldap_uid = s.student_ldap_uid
            AND s.first_reg_term_yr <> 0
        SQL
        statement += " AND p.ldap_uid IN ( #{uids.join(',')} )"

        results = CampusOracle::Queries.connection.execute statement
        results.each do |student|
          found += 1
          if found > number
            exit
          end
          outfile << [student['email_address'], student['first_name'], student['last_name']]
        end
      }
    end
  end

end
