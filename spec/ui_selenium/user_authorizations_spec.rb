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

describe 'User authorization', :testui => true do

  if ENV["UI_TEST"]

    before(:each) do
      @driver = WebDriverUtils.driver
    end

    after(:each) do
      @driver.quit
    end

    describe 'View-as' do

      context 'for an admin' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, UserUtils.admin_uid)
          @settings_page = CalCentralPages::SettingsPage.new(@driver)
          @settings_page.load_page(@driver)
          @settings_page.view_as_user('61889')
          @cal_net_auth_page = CalNetAuthPage.new(@driver)
        end
        context 'who enters unauthorized re-auth credentials' do
          it 'logs the admin out of CalCentral' do
            @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.logout_conf_heading_element.visible? }
          end
        end
        context 'who enters invalid re-auth credentials' do
          it 'locks the admin out of CalCentral' do
            @cal_net_auth_page.login('blah', 'blah')
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.password.blank? }
            @dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
            @dashboard_page.load_page(@driver)
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.username.blank? }
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.password.blank? }
          end
        end
      end

      context 'for an unauthorized user' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, '61889')
          @settings_page = CalCentralPages::SettingsPage.new(@driver)
          @settings_page.load_page(@driver)
        end
        it 'offers no view-as interface' do
          expect(@settings_page.view_as_input_element.visible?).to be false
        end
      end
    end

    describe 'UID / SID conversion' do

      context 'for an admin' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, UserUtils.admin_uid)
          @settings_page = CalCentralPages::SettingsPage.new(@driver)
          @settings_page.load_page(@driver)
        end
        it 'allows conversion of UID to SID' do
          @settings_page.convert_id('61889')
          @settings_page.wait_until(timeout=WebDriverUtils.page_event_timeout) { @settings_page.uid_result == '61889' }
          @settings_page.wait_until(timeout=WebDriverUtils.page_event_timeout) { @settings_page.sid_result == '11667051' }
        end
        it 'allows conversion of SID to UID' do
          @settings_page.convert_id('11667051')
          @settings_page.wait_until(timeout=WebDriverUtils.page_event_timeout) { @settings_page.uid_result == '61889' }
          @settings_page.wait_until(timeout=WebDriverUtils.page_event_timeout) { @settings_page.sid_result == '11667051' }
        end
      end

      context 'for an unauthorized user' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, '61889')
          @settings_page = CalCentralPages::SettingsPage.new(@driver)
          @settings_page.load_page(@driver)
        end
        it 'offers no UID/SID conversion interface' do
          expect(@settings_page.uid_sid_input_element.visible?).to be false
        end
      end
    end

    describe 'CC admin' do

      context 'for an admin' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, UserUtils.admin_uid)
          @driver.get("#{WebDriverUtils.base_url}/ccadmin")
          @cal_net_auth_page = CalNetAuthPage.new(@driver)
        end
        context 'who enters unauthorized re-auth credentials' do
          it 'blocks access to CC admin' do
            @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.password.blank? }
            @dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
            @dashboard_page.load_page(@driver)
            @dashboard_page.wait_for_expected_title?
          end
        end
        context 'when invalid re-auth credentials are entered' do
          it 'blocks access to CC admin' do
            @cal_net_auth_page.login('blah', 'blah')
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.password.blank? }
            @dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
            @dashboard_page.load_page(@driver)
            @dashboard_page.wait_for_expected_title?
          end
        end
      end

      context 'for an unauthorized user' do
        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.basic_auth(@driver, '61889')
          @driver.get("#{WebDriverUtils.base_url}/ccadmin")
          @cal_net_auth_page = CalNetAuthPage.new(@driver)
        end
        context 'when unauthorized re-auth credentials are entered' do
          it 'redirects the user to My Dashboard' do
            @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
            @dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
            @dashboard_page.wait_for_expected_title?
          end
        end
        context 'when invalid re-auth credentials are entered' do
          it 'blocks access to CC admin' do
            @cal_net_auth_page.login('blah', 'blah')
            @cal_net_auth_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { @cal_net_auth_page.password.blank? }
            @dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
            @dashboard_page.load_page(@driver)
            @dashboard_page.wait_for_expected_title?
          end
        end
      end
    end
  end
end
