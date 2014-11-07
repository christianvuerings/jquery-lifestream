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

  desc 'Reconfigure Canvas external apps (CALCENTRAL_XML_HOST="https://cc.example.com" CANVAS_HOSTS_TO_CALCENTRALS="https://ucb.beta.example.com=cc-dev.example.com,https://ucb.test.example.com=cc-qa.example.com")'
  task :reconfigure_external_apps => :environment do
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
      Canvas::ReconfigureExternalApps.reconfigure_external_apps(reachable_xml_host, canvas_hosts_to_calcentrals)
      Rails.logger.info("Reconfigured external apps from #{reachable_xml_host} for #{canvas_hosts_to_calcentrals_string}")
    end
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

end
