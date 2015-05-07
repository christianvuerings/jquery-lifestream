require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/settings_page'
require_relative 'pages/google_page'

describe 'Google apps', :testui => true do

  if ENV["UI_TEST"]

    before(:each) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:each) do
      WebDriverUtils.quit_browser(@driver)
    end

    context 'as any user' do

      before(:example) do
        @splash_page = CalCentralPages::SplashPage.new(@driver)
        @splash_page.load_page(@driver)
        @splash_page.click_sign_in_button
        @cal_net = CalNetAuthPage.new(@driver)
        @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
        @settings_page = CalCentralPages::SettingsPage.new(@driver)
        @settings_page.load_page(@driver)
        @settings_page.disconnect_bconnected
        google = GooglePage.new(@driver)
        google.connect_calcentral_to_google(@driver, UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      end

      context 'when connected' do
        it 'shows no "connect" UI' do
          my_dashboard = CalCentralPages::MyDashboardPage.new(@driver)
          my_dashboard.recent_activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(my_dashboard.connect_bconnected_button_element.visible?).to be false
        end
        it 'shows "connected" on Settings' do
          @settings_page.load_page(@driver)
          @settings_page.disconnect_button_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(@settings_page.connect_button?).to be false
          expect(@settings_page.connected_as).to include("#{UserUtils.qa_gmail_username}")
        end
      end

      context 'when disconnecting' do
        it 'keeps you connected if you\'re not sure' do
          @settings_page.load_page(@driver)
          @settings_page.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          @settings_page.disconnect_button
          @settings_page.disconnect_no_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
          @settings_page.disconnect_no_button
          @settings_page.disconnect_no_button_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
          expect(@settings_page.disconnect_button?).to be true
          expect(@settings_page.connect_button?).to be false
          expect(@settings_page.connected_as).to include("#{UserUtils.qa_gmail_username}")
        end
        it 'disconnects you if you\'re sure' do
          @settings_page.load_page(@driver)
          @settings_page.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          @settings_page.disconnect_button
          @settings_page.disconnect_yes_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
          @settings_page.disconnect_yes_button
          @settings_page.disconnect_yes_button_element.when_not_present(timeout=WebDriverUtils.page_event_timeout)
          expect(@settings_page.disconnect_button?).to be false
          expect(@settings_page.connect_button?).to be true
          expect(@settings_page.connected_as?).to be false
          my_dashboard = CalCentralPages::MyDashboardPage.new(@driver)
          my_dashboard.load_page(@driver)
          my_dashboard.connect_bconnected_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(my_dashboard.connect_bconnected_button?).to be true
        end
      end

      context 'when a connected but opting out of CalCentral' do
        it 'disconnects the user from Google apps' do
          my_dashboard = CalCentralPages::MyDashboardPage.new(@driver)
          my_dashboard.opt_out(@driver)
          @splash_page.wait_for_expected_title?
          @splash_page.click_sign_in_button
          @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
          my_dashboard.connect_bconnected_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(my_dashboard.connect_bconnected_button?).to be true
        end
      end

      context 'when connected as a user without current student classes' do
        it 'shows no "class calendar" option for a non-student' do
          @settings_page.load_page(@driver)
          @settings_page.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(@settings_page.calendar_opt_in?).to be false
        end
      end

    end

    context 'as a student with current student enrollment' do

      context 'when connected' do
        before(:example) do
          @splash_page = CalCentralPages::SplashPage.new(@driver)
          @splash_page.load_page(@driver)
          @splash_page.click_sign_in_button
          cal_net = CalNetAuthPage.new(@driver)
          cal_net.login(UserUtils.oski_username, UserUtils.oski_password)
          @settings_page = CalCentralPages::SettingsPage.new(@driver)
          @settings_page.load_page(@driver)
          @settings_page.disconnect_bconnected
          google = GooglePage.new(@driver)
          google.connect_calcentral_to_google(@driver, UserUtils.oski_gmail_username, UserUtils.oski_gmail_password)
        end
        it 'shows a "class calendar" option' do
          @settings_page.load_page(@driver)
          @settings_page.connected_as_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
          expect(@settings_page.calendar_opt_in_element.enabled?).to be true
          expect(@settings_page.calendar_opt_in_element.checked?).to be false
        end
      end

    end
  end
end
