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
require_relative 'pages/my_dashboard_up_next_card'
require_relative 'pages/google_page'

describe 'My Dashboard bConnected live updates', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    today = Time.now
    id = today.to_i.to_s

    before(:all) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    before(:context) do
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button
      cal_net_auth_page = CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      settings_page = CalCentralPages::SettingsPage.new(@driver)
      settings_page.load_page(@driver)
      settings_page.disconnect_bconnected

      @google = GooglePage.new(@driver)
      @google.connect_calcentral_to_google(@driver, UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)

      # On To Do card, get initial count of unscheduled tasks
      @to_do_card = CalCentralPages::MyDashboardPage::MyDashboardToDoCard.new(@driver)
      @to_do_card.click_unscheduled_tasks_tab
      @to_do_card.unsched_task_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      @initial_task_count = @to_do_card.unsched_task_count.to_i
      logger.info("Unscheduled task count is #{@initial_task_count.to_s}")

      # On email badge, get initial count of unread emails
      @dashboard = CalCentralPages::MyDashboardPage.new(@driver)
      @dashboard.email_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      @initial_mail_count = @dashboard.email_count.to_i
      logger.info("Unread email count is #{@initial_mail_count.to_s}")

      # Send email to self and create new unscheduled task.
      @google.load_gmail(@driver)
      @email_subject = "Test email #{id}"
      @email_summary = "This is the subject of test email #{id}"
      @google.send_email(UserUtils.qa_gmail_username, @email_subject, @email_summary)
      @task_title = "Test task #{id}"
      @google.load_calendar(@driver)
      @google.create_unsched_task(@driver, @task_title)

      # On the Dashboard, wait for the live update to occur
      @dashboard.load_page(@driver)
      @dashboard.click_live_update_button(WebDriverUtils.mail_live_update_timeout)
    end

    context 'for Google mail and tasks' do

      # If initial unread email count is zero, then it probably didn't load correctly.  In such case, ignore this example.
      unless @initial_mail_count == 0
        it 'shows an updated count of email messages' do
          expect(@dashboard.email_count).to eql((@initial_mail_count + 1).to_s)
        end
      end

      it 'shows a snippet of a new email message' do
        @dashboard.show_unread_email
        expect(@dashboard.email_one_sender).to eql('me')
        expect(@dashboard.email_one_subject).to eql(@email_subject)
        expect(@dashboard.email_one_summary).to eql(@email_summary)
      end

      it 'shows an updated count of tasks' do
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.unsched_task_count_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        expect(@to_do_card.unsched_task_count).to eql((@initial_task_count + 1).to_s)
      end

      it 'shows the content of a new task' do
        @to_do_card.click_unscheduled_tasks_tab
        expect(@to_do_card.unsched_task_one_title).to eql(@task_title)
        expect(@to_do_card.unsched_task_one_date).to eql(today.strftime("%m/%d"))
      end
    end
  end
end
