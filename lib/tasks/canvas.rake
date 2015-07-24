namespace :canvas do

  def test_servers
    if (dev_test_canvases_string = ENV["DEV_TEST_CANVASES"])
      dev_test_canvases_string.split(',')
    else
      Settings.canvas_proxy.test_servers
    end
  end

  desc 'Get all Canvas users and sections for current terms, refresh user accounts, and update all section memberships'
  task :batch_refresh => :environment do
    canvas_worker = CanvasCsv::RefreshAllCampusData.new 'batch'
    canvas_worker.run
  end

  desc 'Add new guest user accounts, and update existing ones, within Canvas'
  task :guest_user_sync => :environment do
    canvas_worker = CanvasCsv::Ldap.new
    canvas_worker.update_guests
  end

  desc 'Performs incremental sync of new active CalNet users in Canvas'
  task :new_user_sync => :environment do |t, args|
    canvas_worker = CanvasCsv::AddNewUsers.new
    canvas_worker.sync_new_active_users
  end

  desc 'Exports Canvas enrollments to CSV files for each term'
  task :export_enrollments_to_csv_set => :environment  do
    canvas_worker = CanvasCsv::TermEnrollments.new
    canvas_worker.export_enrollments_to_csv_set
  end

  desc 'Get all Canvas users and sections for current terms, refresh user accounts, and add new section memberships'
  task :incremental_refresh => :environment do
    canvas_worker = CanvasCsv::RefreshAllCampusData.new 'incremental'
    canvas_worker.run
  end

  desc 'Add QA/Dev admin (TEST_ADMIN_ID="some_test_admin" DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com")'
  task :add_test_admin => :environment do
    test_admin_id = ENV["TEST_ADMIN_ID"] || Settings.canvas_proxy.test_admin_id
    non_production_canvases = test_servers
    if test_admin_id.blank?
      Rails.logger.error 'Must specify TEST_ADMIN_ID="some_test_admin"'
    elsif non_production_canvases.blank?
      Rails.logger.error 'Must specify DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com"'
    else
      Canvas::Admins.add_admin_to_servers(test_admin_id, non_production_canvases)
      Rails.logger.info "Admins update complete for #{non_production_canvases}"
    end
  end

  desc 'Reconfigure CAS URL (TEST_CAS_URL="https://auth-test.example.com/cas" DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com")'
  task :reconfigure_auth_url => :environment do
    test_cas_url = ENV["TEST_CAS_URL"] || Settings.canvas_proxy.test_cas_url
    non_production_canvases = test_servers
    if test_cas_url.blank?
      Rails.logger.error 'Must specify TEST_CAS_URL="https://auth-test.example.com/cas"'
    elsif non_production_canvases.blank?
      Rails.logger.error 'Must specify DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com"'
    else
      CanvasLti::ReconfigureAuthorizationConfigs.reconfigure(test_cas_url, non_production_canvases)
      Rails.logger.info "Reconfiguration complete for #{dev_test_canvases_string}"
    end
  end

  desc 'Configure all default Canvas external apps provided by the current server'
  task :configure_all_apps_from_current_host => :environment do
    results = CanvasLti::ReconfigureExternalApps.new.configure_all_apps_from_current_host
    Rails.logger.info "Configured external apps: #{results}"
  end

  desc 'Repair Canvas Course SIS IDs (TERM_ID=x)'
  task :repair_course_sis_ids => :environment do
    term_id = ENV["TERM_ID"]
    if (term_id.blank?)
      Rails.logger.error "Must specify TERM_ID=YourSisTermId"
    else
      canvas_worker = CanvasCsv::RepairSections.new
      canvas_worker.repair_sis_ids_for_term(term_id)
    end
  end

  desc 'Manage Webcast tool placement across all Canvas course sites'
  task :webcast_lti_refresh => :environment do
    Rails.logger.warn "Begin Webcast LTI refresh on #{Settings.canvas_proxy.url_root} (Canvas)"
    global_tools = Canvas::ExternalTools.public_list[:globalTools]
    webcast_tool = global_tools && global_tools.select{ |tool, id| tool =~ /webcast/i }
    if webcast_tool.empty?
      Rails.logger.error 'Webcast tool not found within Canvas globalTools set'
    elsif webcast_tool.length > 1
      Rails.logger.error "Why did we find multiple Webcast tools (#{webcast_tool}) within Canvas globalTools set?! Abort!"
    else
      tool_id = webcast_tool.values.first
      sis_term_ids = Canvas::Terms.current_sis_term_ids
      filtered_ids = sis_term_ids.reject do |id|
        id.end_with?('A') || id.end_with?('C')
      end
      Rails.logger.warn "#{sis_term_ids} are current SIS terms per Canvas. Webcast LTI refresh will use only #{filtered_ids}"
      refresh = CanvasLti::WebcastLtiRefresh.new(filtered_ids, tool_id).refresh_canvas
      Rails.logger.warn "Webcast tool (id = #{tool_id}) refreshed on #{refresh.length} Canvas course sites"
    end
  end

  desc 'Report TurnItIn usage for a term'
  task :report_turnitin => :environment do
    CanvasCsv::TurnitinReporter.print_term_report(ENV['TERM_ID'])
  end

end
