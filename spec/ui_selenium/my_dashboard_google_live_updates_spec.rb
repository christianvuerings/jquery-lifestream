require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_to_do_card'
require_relative 'pages/google_page'

describe 'My Dashboard bConnected live updates', :testui => true do

  if ENV["UI_TEST"]
    
    include ClassLogger

    id = Time.now.to_i.to_s

    before(:all) do
      @driver = WebDriverUtils.driver

      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      settings_page = CalCentralPages::SettingsPage.new(@driver)
      settings_page.load_page(@driver)
      settings_page.disconnect_bconnected(@driver)

      # Get initial count of unread email and unscheduled tasks
      @google = GooglePage.new(@driver)
      @google.connect_calcentral_to_google(@driver, UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      @to_do_card = CalCentralPages::MyDashboardPage::MyDashboardToDoCard.new(@driver)
      @to_do_card.click_unscheduled_tasks_tab
      @to_do_card.unsched_task_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      @initial_task_count = @to_do_card.unsched_task_count.to_i
      logger.info('Unscheduled task count is ' + @initial_task_count.to_s)
      @dashboard = CalCentralPages::MyDashboardPage.new(@driver)
      @dashboard.email_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      @initial_mail_count = @dashboard.email_count.to_i
      logger.info('Unread email count is ' + @initial_mail_count.to_s)

      # As test user, send email to self and create new unscheduled task
      @google.load_gmail(@driver)
      @google.send_email(@driver, UserUtils.qa_gmail_username, 'Test email ' + id, 'This is the subject of test email ' + id)
      @google.load_calendar(@driver)
      @google.create_unsched_task(@driver, 'Test task ' + id)
      @dashboard.load_page(@driver)
      @dashboard.click_live_update_button(WebDriverUtils.mail_live_update_timeout)
    end

    after (:all) do
      @driver.quit
    end

    context 'for Google mail' do

      it 'shows a user an updated count of email messages' do
        @dashboard.email_count.should eql((@initial_mail_count + 1).to_s)
      end

      it 'shows a user a snippet of a new email message' do
        @dashboard.show_unread_email
        @dashboard.email_one_sender.should eql("me")
        @dashboard.email_one_subject.should eql('Test email ' + id)
        @dashboard.email_one_summary.should eql('This is the subject of test email ' + id)
      end
    end

    context 'for Google tasks' do

      it 'shows a user an updated count of tasks' do
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.unsched_task_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        @to_do_card.unsched_task_count.should eql((@initial_task_count + 1).to_s)
      end

      it 'shows a user the content of a new task' do
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.unsched_task_one_title.should eql('Test task ' + id)
        @to_do_card.unsched_task_one_date.should eql(Date.today.strftime("%m/%d"))
      end
    end
  end
end
