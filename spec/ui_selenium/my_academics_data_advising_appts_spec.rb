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
      driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users
      testable_users = []
      test_output = UserUtils.initialize_output_csv(self)

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'L&S', 'Has Current Appt', 'Has Past Appt', 'Has Advisor', 'Error?']
      end

      test_users.each do |user|
        if user['advising']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          is_l_and_s = false
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
            if status_api.is_student? && !academics_api.has_no_standing?
              advising_api = ApiMyAdvisingPage.new(driver)
              advising_api.get_json(driver)
              if advising_api.all_future_appts == nil
                logger.info("Advising API returned nothin' for UID #{uid}")
                no_data = true
              else
                my_academics = CalCentralPages::MyAcademicsPage::MyAcademicsAdvisingCard.new(driver)
                my_academics.load_page(driver)
                my_academics.page_heading_element.when_visible(WebDriverUtils.academics_timeout)
                has_advising_card = my_academics.advising_card_heading?
                if academics_api.colleges.include?('College of Letters & Science')
                  is_l_and_s = true
                  it "appears for UID #{uid}" do
                    expect(has_advising_card).to be true
                  end
                  my_academics.advising_card_spinner_element.when_not_visible(timeout=WebDriverUtils.academics_timeout)

                  # FUTURE APPOINTMENTS
                  has_future_appts_heading = my_academics.future_appts_heading_element.visible?
                  acad_future_appts = my_academics.future_appts_elements.length
                  if advising_api.all_future_appts.length > 0
                    has_future_appt = true
                    testable_users.push(uid)
                    acad_future_appt_dates = my_academics.all_future_appt_dates
                    acad_future_appt_times = my_academics.all_future_appt_times
                    acad_future_appt_advisors = my_academics.all_future_appt_advisors
                    acad_future_appt_methods = my_academics.all_future_appt_methods
                    acad_future_appt_locations = my_academics.all_future_appt_locations
                    api_future_appt_dates = advising_api.all_future_appt_dates
                    api_future_appt_times = advising_api.all_future_appt_times
                    api_future_appt_advisors = advising_api.all_future_appt_advisors
                    api_future_appt_methods = advising_api.all_future_appt_methods
                    api_future_appt_locations = advising_api.all_future_appt_locations
                    it "shows a Current Appointments heading for UID #{uid}" do
                      expect(has_future_appts_heading).to be true
                    end
                    it "shows the right future appointment dates for UID #{uid}" do
                      expect(acad_future_appt_dates).to eql(api_future_appt_dates)
                    end
                    it "shows the right future appointment times for UID #{uid}" do
                      expect(acad_future_appt_times).to eql(api_future_appt_times)
                    end
                    it "shows the right future appointment advisors for UID #{uid}" do
                      expect(acad_future_appt_advisors).to eql(api_future_appt_advisors)
                    end
                    it "shows the right future appointment methods for UID #{uid}" do
                      expect(acad_future_appt_methods).to eql(api_future_appt_methods)
                    end
                    it "shows the right future appointment locations for UID #{uid}" do
                      expect(acad_future_appt_locations).to eql(api_future_appt_locations)
                    end
                    update_button_visible = my_academics.update_appt_link_element.visible?
                    context 'by default' do
                      it "shows no Update Appointment link for UID #{uid}" do
                        expect(update_button_visible).to be false
                      end
                    end
                    my_academics.future_appt_toggles_elements.each do |appt|
                      appt.click
                      update_button_revealed = my_academics.update_appt_link?
                      context 'when a future appointment is expanded' do
                        it "shows an Update Appointment link for UID #{uid}" do
                          expect(update_button_revealed).to be true
                        end
                      end
                      appt.click
                      update_button_still_visible = my_academics.update_appt_link?
                      context 'when a future appointment is collapsed' do
                        it "shows no Update Apppointment link for UID #{uid}" do
                          expect(update_button_still_visible).to be false
                        end
                      end
                    end
                  else
                    it "shows no Current Appointments heading for UID #{uid}" do
                      expect(has_future_appts_heading).to be false
                    end
                    it "shows no future appointments for UID #{uid}" do
                      expect(acad_future_appts).to eql(0)
                    end
                  end

                  # PREVIOUS APPOINTMENTS
                  prev_appt_heading_visible = my_academics.prev_appts_heading?
                  prev_appts_visible = my_academics.prev_appts_table?
                  show_prev_button_visible = my_academics.show_prev_appts_button?
                  hide_prev_button_visible = my_academics.hide_prev_appts_button?
                  context 'by default' do
                    it "shows no Previous Appointments heading for UID #{uid}" do
                      expect(prev_appt_heading_visible).to be false
                    end
                    it "shows no previous appointments for UID #{uid}" do
                      expect(prev_appts_visible).to be false
                    end
                  end
                  if advising_api.all_prev_appts.length > 0
                    has_past_appt = true
                    testable_users.push(uid)
                    my_academics.show_prev_appts_button
                    my_academics.prev_appts_table_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
                    prev_appt_heading_revealed = my_academics.prev_appts_heading?
                    show_prev_button_revealed = my_academics.show_prev_appts_button?
                    acad_prev_appt_dates = my_academics.all_prev_appt_dates
                    acad_prev_appt_advisors = my_academics.all_prev_appt_advisors
                    api_prev_appt_dates = advising_api.all_prev_appt_dates
                    api_prev_appt_advisors = advising_api.all_prev_appt_advisors
                    context 'when previous appointments are revealed' do
                      it "shows a Previous Appointments heading for UID #{uid}" do
                        expect(prev_appt_heading_revealed).to be true
                      end
                      it "shows a Hide Previous Appointments button for UID #{uid}" do
                        expect(show_prev_button_revealed).to be true
                      end
                      it "shows the right previous appointments dates for UID #{uid}" do
                        expect(acad_prev_appt_dates).to eql(api_prev_appt_dates)
                      end
                      it "shows the right previous appointments advisors for UID #{uid}" do
                        expect(acad_prev_appt_advisors).to eql(api_prev_appt_advisors)
                      end
                    end
                    my_academics.hide_prev_appts_button
                    my_academics.prev_appts_table_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
                    hide_prev_appt_button_hidden = my_academics.hide_prev_appts_button?
                    show_prev_button_revealed = my_academics.show_prev_appts_button?
                    context 'when previous appointments are hidden' do
                      it "shows no Hide Previous Appointments button for UID #{uid}" do
                        expect(hide_prev_appt_button_hidden).to be false
                      end
                      it "shows a Show Previous Appointments button for UID #{uid}" do
                        expect(show_prev_button_revealed).to be true
                      end
                    end
                  else
                    it "shows no Show Previous Appointments button for UID #{uid}" do
                      expect(show_prev_button_visible).to be false
                    end
                    it "shows no Hide Previous Appointments button for UID #{uid}" do
                      expect(hide_prev_button_visible).to be false
                    end
                  end
                  unless advising_api.college_advisor.nil?
                    has_advisor = true
                    acad_advisor = my_academics.college_advisor_link
                    api_advisor = advising_api.college_advisor
                    it "shows a college advisor link for UID #{uid}" do
                      expect(acad_advisor).to eql(api_advisor)
                    end
                  end
                  has_new_appt_link = my_academics.make_appt_link?
                  it "shows a 'New Appointment' link for UID #{uid}" do
                    expect(has_new_appt_link).to be true
                  end
                else
                  it "does not appear for UID #{uid}" do
                    expect(has_advising_card).to be false
                  end
                end
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, is_l_and_s, has_future_appt, has_past_appt, has_advisor, threw_error]
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
      WebDriverUtils.quit_browser(driver)
    end
  end
end
