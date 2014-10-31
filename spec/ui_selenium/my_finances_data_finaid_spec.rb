require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_fin_aid_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_landing_page'

describe 'My Finances', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.driver
      output_dir = Rails.root.join('tmp', 'ui_selenium_ouput')
      unless File.exists?(output_dir)
        FileUtils.mkdir_p(output_dir)
      end
      test_output = Rails.root.join(output_dir, 'my_finances_data_finaid.csv')
      logger.info('Opening output CSV')
      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Finances Tab']
      end
      logger.info('Loading test users')
      test_users = JSON.parse(File.read(WebDriverUtils.live_users))['users']

      # CREATE NEW FINAID TIMEOUT IN UTILS

      test_users.each do |user|
        if user['finances']
          uid = user['uid'].to_s
          logger.info('UID is ' + uid)
          has_finances_tab = false
          has_finaid = false
          # has_alert
          # has_message
          # has_info
          # has_date
          # has_current_term_year
          # has_previous_term_year
          # has_next_term_year

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            has_finances_tab = status_api_page.has_finances_tab?
            finaid_api_page = ApiMyFinAidPage.new(driver)
            finaid_api_page.get_json(driver)
            if has_finances_tab

              my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new(driver)
              my_finances_page.load_page(driver)
              my_finances_page.wait_for_fin_aid

              has_no_message_message = my_finances_page.no_messages_message_element.visible?
              if finaid_api_page.all_activity == nil
                it "shows a 'no messages' message for UID #{uid}" do
                  expect(has_no_message_message).to be true
                end
              else
                it "shows no 'no messages' message for UID #{uid}" do
                  expect(has_no_message_message).to be false
                end
                my_fin_message_ttl = my_finances_page.all_finaid_messages_elements.length
                fin_api_message_ttl = finaid_api_page.all_activity.length
                it "shows all the messages from the API for UID #{uid}" do
                  expect(my_fin_message_ttl).to eql(fin_api_message_ttl)
                end
                my_fin_message_sequence =
                fin_api_message_sequence =
                it "shows undated messages in alphabetical order followed by dated message is reverse date order for UID #{uid}" do
                  expect(my_fin_message_sequence).to eql(fin_api_message_sequence)
                end

                logger.info("There are #{my_finances_page.all_finaid_messages_elements.length.to_s} messages for UID #{uid}")
                my_finances_page.all_finaid_messages_elements.each do |item|
                  text = item.text
                  logger.info("Message is #{text}")
                end
                logger.info("Now I'm gonna list all the API messages in the expected sequence for UID #{uid}")
                finaid_api_page.all_messages_sorted.each do |message|
                  logger.info("#{finaid_api_page.title(message)}")
                end
              end



              #   GET ALL MESSAGES OF TYPE BLAH
              #   FOR EACH NON-DUPE MAKE SURE
              #     ICON
              #     TITLE
              #     SOURCE
              #     DATE (IF NOT NULL)
              #     STATUS (IF NOT NULL)
              #     TERM YEAR (IF NOT NULL)
              #     BODY (IF NOT NULL)
              #   FOR EACH SET OF DUPES MAKE SURE
              #     SAME AS ABOVE BUT NESTED INSIDE ANOTHER
              #   FOR ALL VERIFY
              #     SORT ORDER (SOME IN TOP)
              #       those with no date go on top in ascending alphabetical order
              #       those with a date go on bottom in descending date order
              #     TOGGLE DETAIL
              #     EXTERNAL LINKS
              #   STATUS POPOVER FOR ALERT ONES

              CSV.open(test_output, 'a+') do |user_info_csv|
                user_info_csv << [uid, has_finances_tab]
              end

            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          end
        end
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      logger.info('Quitting the browser')
      driver.quit
    end
  end
end
