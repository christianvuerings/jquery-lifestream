module Canvas
  require 'csv'

  # Generates and provides interface to CSV files that are generated daily
  # containing data for Canvas enrollments for each term
  class TermEnrollmentsCsv < Csv

    def initialize
      super()
      @canvas_section_id_enrollments = {}
    end

    # Provides term enrollments CSV file path for given date and term_id
    def enrollment_csv_filepath(date, term_id)
      # Prevent collisions between the SIS_ID code and the filesystem.
      sanitized_term_id = term_id.gsub(/[^a-z0-9\-.]+/i, '_')
      "#{@export_dir}/canvas-#{date.to_date.strftime('%F')}-#{sanitized_term_id}-term-enrollments-export.csv"
    end

    # Returns hash containing generate CSV file paths intended for each term
    def term_enrollments_csv_filepaths(set_date = DateTime.now)
      terms = {}
      term_ids = Canvas::Proxy.current_sis_term_ids
      term_ids.each do |term_id|
        terms[term_id] = enrollment_csv_filepath(set_date, term_id)
      end
      terms
    end

    def latest_term_enrollment_set_date
      @latest_set_date ||= Canvas::Synchronization.get.latest_term_enrollment_csv_set.to_date
    end

    # Exports enrollments from Canvas to CSV set for current day
    def export_enrollments_to_csv_set
      term_enrollments_csv_filepaths.each do |term, filepath|
        summarized_term_enrollments_csv = make_enrollment_export_csv(filepath)
        populate_term_csv_file(term, summarized_term_enrollments_csv)
        summarized_term_enrollments_csv.close
        term_enrollments_count = csv_count(filepath)
        logger.warn("Finished compiling #{filepath}")
        logger.warn("Loaded #{term_enrollments_count} Canvas enrollment records for #{term}")
      end
      sync_settings = Canvas::Synchronization.get
      sync_settings.update(:latest_term_enrollment_csv_set => DateTime.now)
    end

    # Populates the enrollments CSV for the specified term
    def populate_term_csv_file(term, enrollments_csv)
      canvas_sections_csv = Canvas::SectionsReport.new.get_csv(term)
      return if canvas_sections_csv.empty?
      canvas_section_ids = canvas_sections_csv.collect { |row| row['canvas_section_id'] }
      canvas_section_ids.each do |canvas_section_id|
        canvas_section_enrollments = Canvas::SectionEnrollments.new(section_id: canvas_section_id).list_enrollments
        canvas_section_enrollments.each do |enrollment|
          enrollments_csv << self.class.api_to_csv_enrollment(enrollment)
        end
      end
    end

    def make_enrollment_export_csv(filepath)
      make_csv(filepath, 'canvas_section_id,sis_section_id,canvas_user_id,sis_login_id,role,sis_import_id', nil)
    end

    # Loads current term CSVs into memory
    def load_current_term_enrollments
      @canvas_section_id_enrollments = {}
      term_set = term_enrollments_csv_filepaths(latest_term_enrollment_set_date)
      term_set.each do |term,filepath|
        term_csv = CSV.read(filepath, {headers: true})
        # section ids are not going to overlap acros terms, so merging is safe
        @canvas_section_id_enrollments.merge!(term_csv.group_by {|row| row['sis_section_id']})
      end
      @canvas_section_id_enrollments
    end

    # Provides enrollments for Canvas SIS Section ID specified from latest Cached CSV Set
    def cached_canvas_section_enrollments(canvas_sis_section_id)
      load_current_term_enrollments if @canvas_section_id_enrollments.empty?
      @canvas_section_id_enrollments[canvas_sis_section_id].collect {|e| self.class.csv_to_api_enrollment(e) }
    end

    # Converts Canvas Enrollments API hash to CSV hash
    def self.api_to_csv_enrollment(api_enrollment)
      api_enrollment_hash = api_enrollment.to_hash
      {
        'canvas_section_id' => api_enrollment_hash['course_section_id'],
        'sis_section_id' => api_enrollment_hash['sis_section_id'],
        'canvas_user_id' => api_enrollment_hash['user_id'],
        'role' => api_enrollment_hash['role'],
        'sis_import_id' => api_enrollment_hash['sis_import_id'],
        'sis_login_id' => api_enrollment_hash['user']['sis_login_id'],
      }
    end

    # Converts Canvas Enrollments API hash to CSV hash
    def self.csv_to_api_enrollment(csv_enrollment)
      csv_enrollment_hash = csv_enrollment.to_hash
      {
        'course_section_id' => csv_enrollment_hash['canvas_section_id'],
        'sis_section_id' => csv_enrollment_hash['sis_section_id'],
        'user_id' => csv_enrollment_hash['canvas_user_id'],
        'role' => csv_enrollment_hash['role'],
        'sis_import_id' => csv_enrollment_hash['sis_import_id'],
        'user' => {
          'sis_login_id' => csv_enrollment_hash['sis_login_id'],
          'login_id' => csv_enrollment_hash['sis_login_id']
        }
      }
    end

  end
end
