require 'csv'

module SIS
  class PopulateLectureInstanceEnrollment

    def initialize(file, dir)
      @sections = CSV.open(file, :headers => true)
      # Read to pick up the header. We need to rewind afterward, so as not to
      # lose the first line of data in the each() loop.
      @sections.readline
      sections_provisioning_header = 'canvas_section_id,section_id,canvas_course_id,course_id,name,status,start_date,end_date,canvas_account_id,account_id'
      validate_section_header(@sections.headers, sections_provisioning_header)
      target_csv_files = {
        users: 'user_id,login_id,first_name,last_name,email,status',
        enrollments: 'course_id,user_id,role,section_id,status,associated_user_id',
      }
      @output_files = {}
      Dir.open(dir) { |target_dir|
        target_csv_files.each do |file, header|
          abs_file_path = File.join(target_dir.path, file.to_s + '.csv')
          if File.exists?(abs_file_path)
            Rails.logger.info "Removing existing file #{abs_file_path}"
            File.delete(abs_file_path)
          end
          new_file = CSV.open(abs_file_path, 'wb', :headers => true)
          new_file << header.parse_csv
          @output_files[file] = {}
          @output_files[file][:file] = new_file
          @output_files[file][:headers] = new_file.headers
        end
      }
    end

    def populate_section_enrollments
      students_hash = {}
      enrollments_count = {}
      # Rewind before looping
      @sections.rewind
      @sections.each do |row|
        next if row.blank?
        section_entry = row.to_hash
        begin
          section = SIS::SlugParsers.parse_section_slug section_entry['section_id']
        rescue ArgumentError => e
          Rails.logger.warn "Unable to process entry #{section_entry['section_id']}. Skipping"
          next
        end
        students = CampusData.get_enrolled_students(section[:ccn], section[:year], section[:term_cd])
        next if students.blank?

        students.each_with_index do |hash, index|
          result = add_student_to_users! hash["ldap_uid"], @output_files[:users], students_hash
          if result
            enrollment_result = add_student_to_section_enrollment result["user_id"], section_entry, @output_files[:enrollments]
            enrollments_count[section_entry['section_id']] ||= 0
            enrollments_count[section_entry['section_id']]  += 1 if enrollment_result
          end
        end
      end

      {
        added_students: students_hash.size,
        added_enrollments: enrollments_count
      }
    end

    def finalize
      Rails.logger.debug 'Cleaning up opened files'
      @sections.close
      @output_files.each {|key, file| file[:file].close unless file[:file].closed? }
    end

    private

    def add_student_to_users!(student_uid, users_csv, users_hash)
      return if student_uid.empty?
      person_details = CampusData.get_person_attributes student_uid
      new_entry = {
        "user_id" => "#{student_uid}",
        "login_id" => student_uid,
        "first_name" => person_details["first_name"],
        "last_name" => person_details["last_name"],
        "email" => person_details["email_address"],
        "status" => 'active'
      }
      new_entry.select! {|key, value| users_csv[:headers].include? key}
      if users_hash[new_entry["user_id"]].nil?
        users_csv[:file] << new_entry
        users_hash[new_entry["user_id"]] = new_entry
      end
      return new_entry
    end

    def add_student_to_section_enrollment(user_id, canvas_section, enrollments_csv)
      return if user_id.empty?
      new_enrollment = {
        'course_id' => canvas_section['course_id'],
        'user_id' => user_id,
        'role' => 'student',
        'section_id' => canvas_section['section_id'],
        'status' => 'active'
      }
      new_enrollment.select! {|key, value| enrollments_csv[:headers].include? key}
      enrollments_csv[:file] << new_enrollment
      return true
    end

    def validate_section_header(actual_header, valid_header_string)
      valid_header = valid_header_string.split(',').sort
      sorted_header = actual_header.sort
      if sorted_header != valid_header
        raise ArgumentError, "Sections file header (#{sorted_header.join(',')}) does not match provisioning report header (#{valid_header.join(',')}) for sections"
      end
    end

  end
end
