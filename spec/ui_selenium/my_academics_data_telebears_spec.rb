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
      output_dir = Rails.root.join('tmp', 'ui_selenium_ouput')
      unless File.exists?(output_dir)
        FileUtils.mkdir_p(output_dir)
      end
      test_output = Rails.root.join(output_dir, 'my_academics_data_telebears.csv')
      logger.info 'Opening output CSV'
      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Has Tele-BEARS', 'Adviser Message', 'Phase I Start', 'Phase I End', 'Phase II Start',
                          'Phase II End', 'Error Occurred']
      end
      logger.info 'Loading test users'
      test_users = JSON.parse(File.read(WebDriverUtils.live_users))['users']

      test_users.each do |user|
        if user['teleBears']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_tele_bears = false
          code_required_api = nil
          phase_one_start_api = nil
          phase_one_end_api = nil
          phase_two_start_api = nil
          phase_two_end_api = nil
          threw_error = false

          begin
            splash_page = CalCentralPages::SplashPage.new driver
            splash_page.load_page driver
            splash_page.basic_auth(driver, uid)
            academics_api = ApiMyAcademicsPage.new driver
            academics_api.get_json driver
            if academics_api.has_tele_bears
              has_tele_bears = true
              code_required_api = academics_api.tele_bears_code_required
              code_required_msg_api = academics_api.tele_bears_code_message
              phase_one_start_api = academics_api.tele_bears_phase_start academics_api.tele_bears_phases[0]
              phase_one_end_api = academics_api.tele_bears_phase_end academics_api.tele_bears_phases[0]
              phase_two_start_api = academics_api.tele_bears_phase_start academics_api.tele_bears_phases[1]
              phase_two_end_api = academics_api.tele_bears_phase_end academics_api.tele_bears_phases[1]

              # Appointments on main My Academics page
              my_academics_page = CalCentralPages::MyAcademicsPage::MyAcademicsTeleBearsCard.new driver
              my_academics_page.load_page driver
              my_academics_page.adviser_code_msg_element.when_visible WebDriverUtils.academics_timeout
              has_more_info_link_acad = my_academics_page.more_info_link?
              has_red_code_icon_acad = my_academics_page.code_required_icon?
              has_green_code_icon_acad = my_academics_page.code_not_required_icon?
              code_required_msg_acad = my_academics_page.adviser_code_msg
              phase_one_start_acad = my_academics_page.phase_one_start_time
              phase_one_end_acad = my_academics_page.phase_one_end_time
              phase_two_start_acad = my_academics_page.phase_two_start_time
              phase_two_end_acad = my_academics_page.phase_two_end_time
              if code_required_api == true
                it "shows a red code-required icon on My Academics for UID #{uid}" do
                  expect(has_red_code_icon_acad).to be true
                end
              else
                it "shows a green code-required icon on My Academics for UID #{uid}" do
                  expect(has_green_code_icon_acad).to be true
                end
              end
              it "shows the code-required message on My Academics for UID #{uid}" do
                expect(code_required_msg_acad).to eql(code_required_msg_api)
              end
              it "shows the right phase one start time on My Academics for #{uid}" do
                expect(phase_one_start_acad).to eql(phase_one_start_api)
              end
              it "shows the right phase one end time on My Academics for #{uid}" do
                expect(phase_one_end_acad).to eql(phase_one_end_api)
              end
              it "shows the right phase two start time on My Academics for #{uid}" do
                expect(phase_two_start_acad).to eql(phase_two_start_api)
              end
              it "shows the right phase two end time on My Academics for #{uid}" do
                expect(phase_two_end_acad).to eql(phase_two_end_api)
              end
              it "shows a More Info link on My Academics for UID #{uid}" do
                expect(has_more_info_link_acad).to be true
              end

              # Appointments on semester page
              tele_bears_term = academics_api.tele_bears_term_year
              if my_academics_page.has_student_semester_link(driver, tele_bears_term)
                my_academics_page.click_first_student_semester
                my_academics_page.adviser_code_msg_element.when_visible WebDriverUtils.academics_timeout
                has_more_info_link_semester = my_academics_page.more_info_link?
                has_red_code_icon_semester = my_academics_page.code_required_icon?
                has_green_code_icon_semester = my_academics_page.code_not_required_icon?
                code_required_msg_semester = my_academics_page.adviser_code_msg
                phase_one_start_semester = my_academics_page.phase_one_start_time
                phase_one_end_semester = my_academics_page.phase_one_end_time
                phase_two_start_semester = my_academics_page.phase_two_start_time
                phase_two_end_semester = my_academics_page.phase_two_end_time
                if code_required_api == true
                  it "shows a red code-required icon on the semester page for UID #{uid}" do
                    expect(has_red_code_icon_semester).to be true
                  end
                else
                  it "shows a green code-required icon on the semester page for UID #{uid}" do
                    expect(has_green_code_icon_semester).to be true
                  end
                end
                it "shows the code-required message on the semester page for UID #{uid}" do
                  expect(code_required_msg_semester).to eql(code_required_msg_api)
                end
                it "shows the right phase one start time on the semester page for #{uid}" do
                  expect(phase_one_start_semester).to eql(phase_one_start_api)
                end
                it "shows the right phase one end time on the semester page for #{uid}" do
                  expect(phase_one_end_semester).to eql(phase_one_end_api)
                end
                it "shows the right phase two start time on the semester page for #{uid}" do
                  expect(phase_two_start_semester).to eql(phase_two_start_api)
                end
                it "shows the right phase two end time on the semester page for #{uid}" do
                  expect(phase_two_end_semester).to eql(phase_two_end_api)
                end
                it "shows a More Info link on the semester page for UID #{uid}" do
                  expect(has_more_info_link_semester).to be true
                end
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
      logger.info 'Quitting the browser'
      driver.quit
    end
  end
end