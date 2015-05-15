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

describe 'My Finances financial aid messages', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_output = UserUtils.initialize_output_csv(self)
      test_users = UserUtils.load_test_users
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Finances Tab', 'Has Messages', 'Has Dupe Messages', 'Has Popover Alert', 'Has Alert Msg',
                          'Has Info Msg', 'Has Message Msg', 'Has Financial Msg', 'Has Dated Msg', 'Error?']
      end

      test_users.each do |user|
        if user['finAid']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_finances_tab = false
          has_messages = false
          has_dupe_messages = false
          has_popover_alert = false
          has_alert = false
          has_info = false
          has_message = false
          has_financial = false
          has_date = false
          threw_error = false

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
                testable_users.push(uid)
                it "shows no 'no messages' message for UID #{uid}" do
                  expect(has_no_messages_message).to be false
                end
                # If user has dupe messages, record the fact and throw the user out of the test
                if my_finances_page.finaid_message_sub_activity_elements.length > 0
                  has_dupe_messages = true
                else
                  my_fin_messages = my_finances_page.finaid_message_elements
                  my_fin_message_total = my_fin_messages.length
                  logger.info("There are #{my_fin_messages.length.to_s} messages for UID #{uid}")
                  it "shows all the messages from the API for UID #{uid}" do
                    expect(my_fin_message_total).to eql(fin_api_message_total)
                  end
                  my_fin_message_titles = my_finances_page.all_fin_aid_message_titles
                  my_fin_message_sources = my_finances_page.all_fin_aid_message_sources
                  my_fin_message_dates = my_finances_page.all_fin_aid_message_dates(driver, my_fin_messages)
                  my_fin_message_statuses = my_finances_page.all_fin_aid_message_statuses(driver, my_fin_messages)
                  my_fin_message_icons = my_finances_page.all_fin_aid_message_icons
                  fin_api_message_titles = finaid_api_page.all_message_titles_sorted
                  fin_api_message_sources = finaid_api_page.all_message_sources_sorted
                  fin_api_message_dates = finaid_api_page.all_message_dates_sorted
                  fin_api_message_statuses = finaid_api_page.all_message_statuses_sorted
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
                  if fin_api_message_types.include?('financial')
                    has_financial = true
                  end
                  if fin_api_message_dates.length > 0
                    has_date = true
                  end
                  it "shows undated message titles in alphabetical order followed by dated message titles in descending date order for UID #{uid}" do
                    expect(my_fin_message_titles).to eql(fin_api_message_titles)
                  end
                  it "shows the right message icon for UID #{uid}" do
                    expect(my_fin_message_icons).to eql(fin_api_message_types)
                  end
                  it "shows the message source for UID #{uid}" do
                    expect(my_fin_message_sources).to eql(fin_api_message_sources)
                  end
                  it "shows the message date for each dated message for UID #{uid}" do
                    expect(my_fin_message_dates).to eql(fin_api_message_dates)
                  end
                  it "shows the message status for UID #{uid}" do
                    expect(my_fin_message_statuses).to eql(fin_api_message_statuses)
                  end

                  # Status popover
                  has_popover = my_finances_page.status_icon_element.visible?
                  if has_popover
                    my_finances_page.open_status_popover
                    has_popover_alert = my_finances_page.finaid_status_alert_element.visible?
                    if has_alert
                      popover_fin_aid_count = my_finances_page.finaid_status_alert_count
                      fin_api_alert_count = finaid_api_page.all_undated_alert_messages.length.to_s
                      has_red_fin_aid_icon = my_finances_page.finaid_status_alert_icon_element.visible?
                      has_fin_aid_link = my_finances_page.finaid_status_alert_link_element.visible?
                      it "shows Fin Aid alert message in the status popover for UID #{uid}" do
                        expect(has_popover_alert).to be true
                      end
                      it "shows the right number of Fin Aid alerts in the status popover for UID #{uid}" do
                        expect(popover_fin_aid_count).to eql(fin_api_alert_count)
                      end
                      it "shows a red Fin Aid alert icon in the status popover for UID #{uid}" do
                        expect(has_red_fin_aid_icon).to be true
                      end
                      it "offers a link from the status popover to the My Finances page for UID #{uid}" do
                        expect(has_fin_aid_link).to be true
                      end
                    else
                      it "shows no Fin Aid alert message in the status popover for UID #{uid}" do
                        expect(has_popover_alert).to be false
                      end
                    end
                  end

                  finaid_api_page.all_messages_sorted.each do |message|
                    index = finaid_api_page.all_messages_sorted.index(message)
                    my_finances_page.finaid_message_toggle_elements[index].click
                    my_fin_message_year = my_finances_page.all_fin_aid_message_years[index]
                    my_fin_message_summary = my_finances_page.all_fin_aid_message_summaries(driver, my_fin_messages)[index]
                    my_fin_message_url = my_finances_page.all_fin_aid_message_links[index]
                    fin_api_message_year = finaid_api_page.all_message_years_sorted[index]
                    fin_api_message_summary = finaid_api_page.all_message_summaries_sorted[index]
                    fin_api_message_url = finaid_api_page.all_message_source_urls_sorted[index]
                    it "shows the message term year for UID #{uid}" do
                      expect(my_fin_message_year).to eql("Academic Year: #{fin_api_message_year}")
                    end
                    it "shows the message summary for UID #{uid}" do
                      expect(my_fin_message_summary).to eql(fin_api_message_summary)
                    end
                    it "shows an external message link for UID #{uid}" do
                      expect(my_fin_message_url).to eql(fin_api_message_url)
                    end
                  end
                end
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, has_finances_tab, has_messages, has_dupe_messages, has_popover_alert, has_alert, has_info, has_message,
                                has_financial, has_date, threw_error]
            end
          end
        end
      end

        it 'has FinAid messages for at least one of the test UIDs' do
          expect(testable_users.any?).to be true
        end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
