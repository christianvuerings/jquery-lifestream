module CanvasCsv
  require 'csv'

  class Base < CsvExport
    include ClassLogger

    def initialize
      super(Settings.canvas_proxy.export_directory)
    end

    def accumulate_user_data(user_ids)
      users = []
      user_ids.each_slice(1000) do |uid_slice|
        campus_results = CampusOracle::Queries.get_basic_people_attributes uid_slice
        users.concat campus_results.map { |row| canvas_user_from_campus_row row }
      end
      users
    end

    def canvas_user_from_campus_row(campus_user)
      {
        'user_id' => derive_sis_user_id(campus_user),
        'login_id' => campus_user['ldap_uid'].to_s,
        'password' => nil,
        'full_name' => "#{campus_user['first_name']} #{campus_user['last_name']}",
        'email' => campus_user['email_address'],
        'status' => 'active'
      }
    end

    def derive_sis_user_id(campus_user)
      if Settings.canvas_proxy.mixed_sis_user_id
        roles = Berkeley::UserRoles.roles_from_campus_row(campus_user)
        if campus_user['student_id'].present? &&
          (roles[:student] || roles[:concurrentEnrollmentStudent])
          campus_user['student_id'].to_s
        else
          "UID:#{campus_user['ldap_uid']}"
        end
      else
        campus_user['ldap_uid'].to_s
      end
    end

    def make_csv(filename, headers, rows)
      csv = CSV.open(
        filename, 'wb',
        {
          headers: headers,
          write_headers: true
        }
      )
      if rows
        rows.each do |row|
          csv << row
        end
        csv.close
        filename
      else
        csv
      end
    end

    def file_safe(string)
      # Prevent collisions with the filesystem.
      string.gsub(/[^a-z0-9\-.]+/i, '_')
    end

    def make_courses_csv(filename, rows = nil)
      make_csv(filename, 'course_id,short_name,long_name,account_id,term_id,status,start_date,end_date', rows)
    end

    def make_enrollments_csv(filename, rows = nil)
      make_csv(filename, 'course_id,user_id,role,section_id,status,associated_user_id', rows)
    end

    def make_sections_csv(filename, rows = nil)
      make_csv(filename, 'section_id,course_id,name,status,start_date,end_date', rows)
    end

    def make_users_csv(filename, rows = nil)
      make_csv(filename, 'user_id,login_id,full_name,email,status', rows)
    end

    def csv_count(csv_filename)
      CSV.read(csv_filename, {headers: true}).length
    end

  end
end
