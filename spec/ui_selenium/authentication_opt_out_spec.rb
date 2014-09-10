require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_to_do_card'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'

describe 'Opting out', :testui => true do

  if ENV["UI_TEST"]

    before(:each) do
      @driver = WebDriverUtils.driver
    end

    after(:each) do
      @driver.quit
    end

    it 'does not prevent a user logging back in' do
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button(@driver)
      cal_net_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_page.login(UserUtils.oski_username, UserUtils.oski_password)
      dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
      dashboard_page.opt_out(@driver)
      cal_net_page.logout_conf_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button(@driver)
      cal_net_page.login(UserUtils.oski_username, UserUtils.oski_password)
      dashboard_page.recent_activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      dashboard_page.wait_for_expected_title?
    end

  end
end
