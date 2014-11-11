module Canvas
  # Adds Canvas users based on differences detected in active CalNet user set and Canvas User Report
  class AddNewUsers < Csv

    require 'set'

    def initialize(options = {})
      super()
    end

    # Performs full new user detection and addition task
    def sync_new_active_users
      prepare_sis_user_import
      get_canvas_user_report_file
      load_new_active_users
      if @new_active_sis_users.count > 0
        process_new_users
        import_sis_user_csv
      else
        logger.warn("No new user accounts detected. New user processing completed.")
      end
    end

    def prepare_sis_user_import
      sis_user_import_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-sync-all-users.csv"
      @sis_user_import = make_users_csv(sis_user_import_filename)
    end

    # Prepares Canvas report containing all users for iteration during processing
    def get_canvas_user_report_file
      get_report = Proc.new {
        filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-users-report.csv"
        csv_table = Canvas::UsersReport.new.get_csv
        headers = csv_table.headers.join(',')
        file = CSV.open(filename, 'wb', { :headers => headers, :write_headers => true})
        logger.warn("Canvas user report obtained containing data on #{csv_table.count} user accounts")
        csv_table.each do |row|
          file << row
        end
        file.close
        file.path
      }
      @canvas_user_report_file_path ||= get_report.call
    end

    def load_new_active_users
      @new_active_sis_users = []
      new_uid_groups = split_uid_array(new_active_user_uids)
      return @new_active_sis_users if new_uid_groups[0].count == 0
      new_uid_groups.each do |uid_group|
        @new_active_sis_users.concat(CampusOracle::Queries.get_basic_people_attributes(uid_group))
      end
      @new_active_sis_users
    end

    # Add remaining users not detected in Canvas to SIS User Import
    def process_new_users
      logger.warn("#{@new_active_sis_users.length} new user accounts detected. Adding to SIS User Import CSV")
      @new_active_sis_users.each do |new_user|
        new_canvas_user = canvas_user_from_campus_row(new_user)
        add_user_to_import(new_canvas_user)
      end
      @new_active_sis_users = nil
    end

    def import_sis_user_csv
      @sis_user_import.close
      csv_filepath = @sis_user_import.path
      user_count = CSV.read(csv_filepath, {headers: true}).length
      if user_count > 0
        logger.warn("Importing SIS User Import CSV with #{user_count} updates")
        Canvas::SisImport.new.import_users(csv_filepath)
      end
    end

    # Split UID array into sets of 1000
    def split_uid_array(uid_array)
      return [uid_array] if uid_array.count < 1001
      split_array = []
      while uid_array.count > 0  do
        split_array << uid_array.slice!(0, 1000)
      end
      return split_array
    end

    # Loads array of new active LDAP people/guests from campus Oracle view
    def new_active_user_uids
      all_active_sis_user_uids = CampusOracle::Queries.get_all_active_people_uids.to_set
      all_current_canvas_uids = []
      CSV.foreach(get_canvas_user_report_file, :headers => :first_row) do |canvas_user|
        all_current_canvas_uids << canvas_user['login_id']
      end
      all_active_sis_user_uids.subtract(all_current_canvas_uids).to_a
    end

    # Adds Canvas User hash to SIS User Import CSV
    def add_user_to_import(canvas_user)
      @sis_user_import << canvas_user
    end

  end
end
