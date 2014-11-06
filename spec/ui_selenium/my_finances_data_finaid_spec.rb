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

  #   TODO: VERIFY STATUS POPOVER CONTENTS (MUST HAVE ALERTS, WITH ICON AND TITLE... NEED PUT BACK IN INNER LOOP)
  #   TODO: FIGURE OUT WHY CSV IS GETTING WRONG VALUES
  #   TODO: FIGURE OUT WHAT TO DO WITH DUPE MESSAGES.  THROW THEM OUT?

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
        user_info_csv << ['UID', 'Finances Tab', 'Has No Messages', 'Has Alert Msg', 'Has Info Msg', 'Has Message Msg', 'Has Dated Msg', 'Error Occurred']
      end
      logger.info('Loading test users')
      test_users = JSON.parse(File.read(WebDriverUtils.live_users))['users']

      test_users.each do |user|
        if user['finAid']
          uid = user['uid'].to_s
          logger.info('UID is ' + uid)
          has_finances_tab = false
          has_messages = false
          has_alert = false
          has_info = false
          has_message = false
          has_date = false
          has_error = false

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
              has_no_messages_message = my_finances_page.no_messages_element.visible?
              fin_api_message_total = finaid_api_page.all_activity.length
              if fin_api_message_total == 0
                it "shows a 'no messages' message for UID #{uid}" do
                  expect(has_no_messages_message).to be true
                end
              else
                has_messages = true
                it "shows no 'no messages' message for UID #{uid}" do
                  expect(has_no_messages_message).to be false
                end
                my_fin_messages = my_finances_page.finaid_message_elements
                my_fin_message_total = my_fin_messages.length
                logger.info("There are #{my_fin_messages.length.to_s} messages for UID #{uid}")
                it "shows all the messages from the API for UID #{uid}" do
                  expect(my_fin_message_total).to eql(fin_api_message_total)
                end
                my_fin_message_titles = my_finances_page.all_fin_aid_message_titles
                fin_api_message_titles = finaid_api_page.all_message_titles_sorted
                logger.info("Message on the page is #{my_fin_message_titles}")
                logger.info("Message in the API is #{fin_api_message_titles}")
                it "shows undated message titles in alphabetical order followed by dated message titles in descending date order for UID #{uid}" do
                  expect(my_fin_message_titles).to eql(fin_api_message_titles)
                end

                my_fin_message_icons = my_finances_page.all_fin_aid_message_icons
                fin_api_message_types = finaid_api_page.all_message_types_sorted
                if fin_api_message_types.include?('alert')
                  has_alert = true
                end
                if fin_api_message_types.include?('info')
                  has_info = true
                end
                if fin_api_message_types.include?('message')
                  has_message = true
                end
                logger.info("Message icon on page is #{my_fin_message_icons}")
                logger.info("Message type in API is #{fin_api_message_types}")
                it "shows the right message icon for UID #{uid}" do
                  expect(my_fin_message_icons).to eql(fin_api_message_types)
                end

                my_fin_message_sources = my_finances_page.all_fin_aid_message_sources
                fin_api_message_sources = finaid_api_page.all_message_sources_sorted
                logger.info("Message source on page is #{my_fin_message_sources}")
                logger.info("Message source in API is #{fin_api_message_sources}")
                it "shows the message source for UID #{uid}" do
                  expect(my_fin_message_sources).to eql(fin_api_message_sources)
                end

                finaid_api_page.all_messages_sorted.each do |message|
                  index = finaid_api_page.all_messages_sorted.index(message)

                  my_fin_message_date = my_finances_page.all_fin_aid_message_dates(driver, my_fin_messages)[index]
                  fin_api_message_date = finaid_api_page.all_message_dates_sorted[index]
                  logger.info("Message date on page is #{my_fin_message_date}")
                  logger.info("Message date in API is #{fin_api_message_date}")
                  it "shows the message date for each dated message for UID #{uid}" do
                    expect(my_fin_message_date).to eql(fin_api_message_date)
                  end

                  my_fin_message_status = my_finances_page.all_fin_aid_message_statuses(driver, my_fin_messages)[index]
                  fin_api_message_status = finaid_api_page.all_message_statuses_sorted[index]
                  logger.info("Message status on page is #{my_fin_message_status}")
                  logger.info("Message status in API is #{fin_api_message_status}")
                  it "shows the message status for UID #{uid}" do
                    expect(my_fin_message_status).to eql(fin_api_message_status)
                  end

                  my_finances_page.finaid_message_toggle_elements[index].click

                  my_fin_message_year = my_finances_page.all_fin_aid_message_years[index]
                  fin_api_message_year = finaid_api_page.all_message_years_sorted[index]
                  it "shows the message term year for UID #{uid}" do
                    expect(my_fin_message_year).to eql("Academic Year: #{fin_api_message_year}")
                  end

                  my_fin_message_summary = my_finances_page.all_fin_aid_message_summaries(driver, my_fin_messages)[index]
                  fin_api_message_summary = finaid_api_page.all_message_summaries_sorted[index]
                  logger.info("Message summary on page is #{my_fin_message_summary}")
                  logger.info("Message summary in API is #{fin_api_message_summary}")
                  it "shows the message summary for UID #{uid}" do
                    expect(my_fin_message_summary).to eql(fin_api_message_summary)
                  end

                  my_fin_message_url = my_finances_page.all_fin_aid_message_links[index]
                  fin_api_message_url = finaid_api_page.all_message_source_urls_sorted[index]
                  logger.info("Message URL on the page is #{my_fin_message_url}")
                  logger.info("Message URL in the API is #{fin_api_message_url}")
                  it "shows an external message link for UID #{uid}" do
                    expect(my_fin_message_url).to eql(fin_api_message_url)
                  end
                end
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            has_error = true
          end
        end
        CSV.open(test_output, 'a+') do |user_info_csv|
          user_info_csv << [uid, has_finances_tab, has_messages, has_alert, has_info, has_message, has_date, has_error]
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
