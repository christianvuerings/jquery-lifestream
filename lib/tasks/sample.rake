# generate lists of emails for marketing purposes.
# this script is deliberately quick and dirty.
# Please customize the query to the particular needs of the day.
# Run the task like so from a production node:
# RAILS_ENV=production rake sample:students N=2000

namespace :sample do

  task :students => :environment do

    users = []
    User::Data.all.each do |user|
      users << user.uid.strip.to_i
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
            return
          end
          outfile << [student['email_address'], student['first_name'], student['last_name']]
        end
      }
    end
  end
end
