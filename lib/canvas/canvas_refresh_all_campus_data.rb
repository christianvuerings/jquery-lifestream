require 'csv'

class CanvasRefreshAllCampusData < CanvasCsv
  include ClassLogger
  attr_accessor :users_csv_filename
  attr_accessor :term_to_memberships_csv_filename

  def initialize
    super
    @users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users.csv"
    @term_to_memberships_csv_filename = {}
    term_ids = CanvasProxy.current_sis_term_ids
    term_ids.each do |term_id|
      # Prevent collisions between the SIS_ID code and the filesystem.
      sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
      csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{sanitized_term_id}-enrollments.csv"
      @term_to_memberships_csv_filename[term_id] = csv_filename
    end
  end

  def run
    make_csv_files
    import_csv_files
  end

  def make_csv_files
    users_csv = make_users_csv(@users_csv_filename)
    known_uids = []
    CanvasMaintainUsers.new.refresh_existing_user_accounts(known_uids, users_csv)
    original_user_count = known_uids.length
    enrollments_maintainer = CanvasMaintainEnrollments.new
    @term_to_memberships_csv_filename.each do |term, csv_filename|
      enrollments_csv = make_enrollments_csv(csv_filename)
      enrollments_maintainer.refresh_existing_term_sections(term, enrollments_csv, known_uids, users_csv)
      enrollments_csv.close
      logger.warn("Will upload #{csv_count(csv_filename)} Canvas enrollment records for #{term}")
    end
    new_user_count = known_uids.length - original_user_count
    users_csv.close
    updated_user_count = csv_count(@users_csv_filename) - new_user_count
    logger.warn("Will upload #{updated_user_count} changed accounts for #{original_user_count} existing users")
    logger.warn("Will upload #{new_user_count} new user accounts")
  end

  # Uploading a single zipped archive containing both users and enrollments would be safer and more efficient.
  # However, a batch update can only be done for one term. If we decide to limit Canvas refreshes
  # to a single term, then we should change this code.
  def import_csv_files
    import_proxy = CanvasSisImportProxy.new
    if import_proxy.import_users(@users_csv_filename)
      logger.warn("User import succeeded")
      @term_to_memberships_csv_filename.each do |term_id, csv_filename|
        if import_proxy.import_all_term_enrollments(term_id, csv_filename)
          logger.warn("Enrollment import succeeded")
        end
      end
    end
  end

  def csv_count(csv_filename)
    CSV.read(csv_filename, {headers: true}).length
  end

end
