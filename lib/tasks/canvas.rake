namespace :canvas do

  desc 'Get all Canvas users and sections for current terms, refresh user accounts, and update all section memberships'
  task :batch_refresh => :environment do
    canvas_worker = Canvas::RefreshAllCampusData.new 'batch'
    canvas_worker.run
  end

  desc 'Add new guest user accounts, and update existing ones, within Canvas'
  task :guest_user_sync => :environment do
    canvas_worker = Canvas::Ldap.new
    canvas_worker.update_guests
  end

  desc 'Performs incremental sync of new active CalNet users in Canvas'
  task :new_user_sync => :environment do |t, args|
    canvas_worker = Canvas::AddNewUsers.new
    canvas_worker.sync_new_active_users
  end

  desc 'Exports Canvas enrollments to CSV files for each term'
  task :export_enrollments_to_csv_set => :environment  do
    canvas_worker = Canvas::TermEnrollmentsCsv.new
    canvas_worker.export_enrollments_to_csv_set
  end

  desc 'Get all Canvas users and sections for current terms, refresh user accounts, and add new section memberships'
  task :incremental_refresh => :environment do
    canvas_worker = Canvas::RefreshAllCampusData.new 'incremental'
    canvas_worker.run
  end

  desc 'Reconfigure CAS URL (TEST_CAS_URL="https://auth-test.example.com/cas" DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com")'
  task :reconfigure_auth_url => :environment do
    test_cas_url = ENV["TEST_CAS_URL"]
    dev_test_canvases_string = ENV["DEV_TEST_CANVASES"]
    if test_cas_url.blank?
      Rails.logger.error('Must specify TEST_CAS_URL="https://auth-test.example.com/cas"')
    elsif dev_test_canvases_string.blank?
      Rails.logger.error('Must specify DEV_TEST_CANVASES="https://ucb.beta.example.com,https://ucb.test.example.com"')
    else
      non_production_canvases = dev_test_canvases_string.split(',')
      Canvas::ReconfigureAuthorizationConfigs.reconfigure(test_cas_url, non_production_canvases)
      Rails.logger.info("Reconfiguration complete for #{dev_test_canvases_string}")
    end
  end

  desc 'Reconfigure Canvas external apps on other servers (CALCENTRAL_XML_HOST="https://cc.example.com" CANVAS_HOSTS_TO_CALCENTRALS="https://ucb.beta.example.com=cc-dev.example.com,https://ucb.test.example.com=cc-qa.example.com")'
  task :reset_external_app_hosts_by_url => :environment do
    reachable_xml_host = ENV["CALCENTRAL_XML_HOST"]
    canvas_hosts_to_calcentrals_string = ENV["CANVAS_HOSTS_TO_CALCENTRALS"]
    if reachable_xml_host.blank?
      Rails.logger.error('Must specify CALCENTRAL_XML_HOST="https://cc.example.com"')
    elsif canvas_hosts_to_calcentrals_string.blank?
      Rails.logger.error('Must specify CANVAS_HOSTS_TO_CALCENTRALS="https://ucb.beta.example.com=cc-dev.example.com,https://ucb.test.example.com=cc-qa.example.com"')
    else
      canvas_hosts_to_calcentrals = []
      canvas_hosts_to_calcentrals_string.split(/=|,/).each_slice(2) {|pair|
        canvas_hosts_to_calcentrals.push({host: pair[0], calcentral: pair[1]})
      }
      Canvas::ReconfigureExternalApps.new.reset_external_app_hosts_by_url(reachable_xml_host, canvas_hosts_to_calcentrals)
      Rails.logger.info("Reconfigured external apps from #{reachable_xml_host} for #{canvas_hosts_to_calcentrals_string}")
    end
  end

  desc 'Configure all default Canvas external apps provided by the current server'
  task :configure_all_apps_from_current_host => :environment do
    results = Canvas::ReconfigureExternalApps.new.configure_all_apps_from_current_host
    Rails.logger.info("Configured external apps: #{results}")
  end

  desc 'Repair Canvas Course SIS IDs (TERM_ID=x)'
  task :repair_course_sis_ids => :environment do
    term_id = ENV["TERM_ID"]
    if (term_id.blank?)
      Rails.logger.error("Must specify TERM_ID=YourSisTermId")
    else
      canvas_worker = Canvas::RepairSections.new
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
      Rails.logger.error "Why did we find multiple Webcast tools (#{webcast_tool.to_s}) within Canvas globalTools set?! Abort!"
    else
      tool_id = webcast_tool.values.first
      Rails.logger.warn "Updating Webcast tool (id = #{tool_id}) configs on all Canvas course sites"
      sis_term_ids = Canvas::Proxy.current_sis_term_ids
      refresh = Canvas::WebcastLtiRefresh.new(sis_term_ids, tool_id).refresh_canvas
      Rails.logger.warn "Webcast tool (id = #{tool_id}) refreshed on #{refresh.length} Canvas course sites"
    end
  end

  desc 'Report TurnItIn usage for a term'
  task :report_turnitin => :environment do
    Canvas::TurnitinReporter.print_term_report(ENV['TERM_ID'])
  end

end
