require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_academics_advising_card'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_academics_page'
require_relative 'pages/api_my_advising_page'

describe 'My Academics L&S Advising card', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.driver
      test_users = UserUtils.load_test_users
      testable_users = []
      test_output = UserUtils.initialize_output_csv(self)

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'L&S', 'Double Major', 'Has Current Appt', 'Has Past Appt', 'Has Advisor', 'Error?']
      end

      test_users.each do |user|
        if user['advising']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          is_l_and_s = false
          is_double_major = false
          has_future_appt = false
          has_past_appt = false
          has_advisor = false
          threw_error = false

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api = ApiMyStatusPage.new(driver)
            status_api.get_json(driver)
            academics_api = ApiMyAcademicsPage.new(driver)
            academics_api.get_json(driver)
            if status_api.is_student?
              advising_api = ApiMyAdvisingPage.new(driver)
              my_academics = CalCentralPages::MyAcademicsPage::MyAcademicsAdvisingCard.new(driver)
              my_academics.load_page(driver)
              logger.info("Colleges are #{academics_api.colleges}")
              if academics_api.colleges.include?('College of Letters & Science')
                is_l_and_s = true
                if advising_api.all_future_appts.length > 0
                  has_future_appt = true


                end
                if advising_api.all_past_appts.length > 0
                  has_past_appt = true


                end
                #     USER HAS ADVISOR?
                #     MAKE NEW APPT (OPENS NEW WINDOW)?

              else
                #     USER HAS NO CARD?
              end

            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, is_l_and_s, is_double_major, has_future_appt, has_past_appt, has_advisor, threw_error]
            end
          end
        end
      end
      it 'has advising appt info for at least one of the test UIDs' do
        expect(testable_users.length).to be > 0
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n")
    ensure
      logger.info 'Quitting the browser'
      driver.quit
    end
  end
end
