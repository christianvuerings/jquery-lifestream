require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_academics_page'
require_relative 'pages/my_academics_tele_bears_card'

describe 'My Academics Tele-BEARS card', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.driver
      test_output = UserUtils.initialize_output_csv(self)
      test_users = UserUtils.open_test_uid_csv

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Has Tele-BEARS', 'Adviser Messages', 'Phase Starts', 'Phase Endings', 'Error Occurred']
      end

      test_users.each do |user|
        if user['teleBears']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_tele_bears = false
          api_adviser_code_msgs = nil
          api_phase_starts = nil
          api_phase_endings = nil
          threw_error = false

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            academics_api = ApiMyAcademicsPage.new(driver)
            academics_api.get_json(driver)
            my_academics_page = CalCentralPages::MyAcademicsPage::MyAcademicsTeleBearsCard.new driver
            my_academics_page.load_page(driver)
            my_academics_page.page_heading_element.when_visible(WebDriverUtils.academics_timeout)
            api_appts_for_all_semesters = academics_api.tele_bears
            if api_appts_for_all_semesters.length > 0
              has_tele_bears = true
              testable_users.push(uid)
              api_adviser_code_reqts = academics_api.tele_bears_adviser_codes(api_appts_for_all_semesters)
              api_adviser_code_msgs = academics_api.tele_bears_adviser_code_msgs(api_appts_for_all_semesters)
              api_phase_starts = academics_api.tele_bears_phase_starts(api_appts_for_all_semesters)
              api_phase_endings = academics_api.tele_bears_phase_endings(api_appts_for_all_semesters)

              # Appointments on main My Academics page
              my_academics_page.tele_bears_card_heading_element.when_visible(WebDriverUtils.academics_timeout)
              acad_has_more_info_link = my_academics_page.more_info_link_elements.length
              acad_adviser_code_reqts = my_academics_page.all_telebears_adviser_icons
              acad_adviser_code_msgs = my_academics_page.all_telebears_adviser_msgs
              acad_phase_starts = my_academics_page.all_phase_start_times
              acad_phase_endings = my_academics_page.all_phase_end_times
              it "shows the right code-required icons on My Academics for UID #{uid}" do
                expect(acad_adviser_code_reqts.sort).to eql(api_adviser_code_reqts.sort)
              end
              it "shows the right code-required messages on My Academics for UID #{uid}" do
                expect(acad_adviser_code_msgs.sort).to eql(api_adviser_code_msgs.sort)
              end
              it "shows the right phase start dates and times on My Academics for #{uid}" do
                expect(acad_phase_starts.sort).to eql(api_phase_starts.sort)
              end
              it "shows the right phase ending dates and times on My Academics for #{uid}" do
                expect(acad_phase_endings.sort).to eql(api_phase_endings.sort)
              end
              it "shows one More Info link on My Academics for UID #{uid}" do
                expect(acad_has_more_info_link).to eql(1)
              end

              # Appointments on semester pages
              api_appts_for_all_semesters.each do |term|
                semester_appts = []
                semester_appts.push(term)
                term_year = academics_api.tele_bears_term_year(semester_appts[0])
                if my_academics_page.has_student_semester_link(driver, term_year)
                  api_semester_adv_code_reqts = academics_api.tele_bears_adviser_codes(semester_appts)
                  api_semester_adv_code_msg = academics_api.tele_bears_adviser_code_msgs(semester_appts)
                  api_semester_phase_starts = academics_api.tele_bears_phase_starts(semester_appts)
                  api_semester_phase_endings = academics_api.tele_bears_phase_endings(semester_appts)

                  my_academics_page.load_semester_page(driver, academics_api.tele_bears_semester_slug(semester_appts[0]))
                  my_academics_page.tele_bears_card_heading_element.when_visible WebDriverUtils.academics_timeout
                  acad_semester_more_info_link = my_academics_page.more_info_semester_link?
                  acad_semester_adv_code_reqts = my_academics_page.all_telebears_adviser_icons
                  acad_semester_adv_code_msgs = my_academics_page.all_telebears_adviser_msgs
                  acad_semester_phase_starts = my_academics_page.all_phase_start_times
                  acad_semester_phase_endings = my_academics_page.all_phase_end_times
                  it "shows the right code-required icons on My Academics for UID #{uid}" do
                    expect(acad_semester_adv_code_reqts.sort).to eql(api_semester_adv_code_reqts.sort)
                  end
                  it "shows the right code-required messages on My Academics for UID #{uid}" do
                    expect(acad_semester_adv_code_msgs.sort).to eql(api_semester_adv_code_msg.sort)
                  end
                  it "shows the right phase start dates and times on My Academics for #{uid}" do
                    expect(acad_semester_phase_starts.sort).to eql(api_semester_phase_starts.sort)
                  end
                  it "shows the right phase ending dates and times on My Academics for #{uid}" do
                    expect(acad_semester_phase_endings.sort).to eql(api_semester_phase_endings.sort)
                  end
                  it "shows a More Info link on My Academics for UID #{uid}" do
                    expect(acad_semester_more_info_link).to be true
                  end
                end
              end
            else
              has_tele_bears_card = my_academics_page.tele_bears_card_heading?
              it "shows no Tele-BEARS information for UID #{uid}" do
                expect(has_tele_bears_card).to be false
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, has_tele_bears, code_required_api, phase_one_start_api, phase_one_end_api, phase_two_start_api,
                                phase_two_end_api, threw_error]
            end
          end
        end
      end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n")
    ensure
      it 'has Tele-BEARS info for at least one of the test UIDs' do
        expect(testable_users.length).to be > 0
      end
      logger.info 'Quitting the browser'
      driver.quit
    end
  end
end
