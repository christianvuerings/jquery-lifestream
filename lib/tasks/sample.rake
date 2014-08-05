# generate lists of emails for marketing purposes.
# this script is deliberately quick and dirty.
# Please customize the query to the particular needs of the day.

namespace :sample do

  task :students => :environment do

    # uids contains a list of all users who have ever logged in to CalCentral.
    # generate the uids.csv file like so by running this on prod-01:
    # psql -h POSTGRES_HOST -p PORT -U calcentral_readonly calcentral -c "select uid from user_data" -t > uids.csv
    uids_file = CSV.read(Rails.root.join('tmp', 'uids.csv'))
    users = []
    uids_file.each_with_index { |row, index|
      users << row[0].strip.to_i
    }

    found = 0
    CSV.open(Rails.root.join('tmp', 'sample_emails.csv'), 'wb') do |outfile|
      users.each_slice(200) { |uids|

        # get students (grad and undergrad) who are not first-years, and who are in uids.csv list
        statement = <<-SQL
          SELECT p.email_address
          FROM calcentral_person_info_vw p, calcentral_student_info_vw s
          WHERE p.ldap_uid = s.student_ldap_uid
            AND s.first_reg_term_yr <> 2014
            AND s.first_reg_term_yr <> 0
        SQL
        statement += " AND p.ldap_uid IN ( #{uids.join(',')} )"

        results = CampusOracle::Queries.connection.execute statement
        results.each do |student|
          found += 1
          if found > 2000
            return
          end
          outfile << [student['email_address']]
        end
      }
    end
  end
end
