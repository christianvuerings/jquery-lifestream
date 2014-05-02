require 'rspec'
require 'selenium-webdriver'
require 'page-object'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/settings_page'
require_relative 'pages/my_dashboard_page'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'

describe 'Opting out', :testui => true do

  before(:all) do
    @driver = WebDriverUtils.driver
    @page_load = WebDriverUtils.page_load_timeout
  end

  after(:all) do
    @driver.quit
  end

  it 'does not prevent a user logging back in' do
    splash_page = CalCentralPages::SplashPage.new(@driver)
    splash_page.load_page(@driver)
    splash_page.click_sign_in_button(@driver)
    cal_net_page = CalNetPages::CalNetAuthPage.new(@driver)
    cal_net_page.login_admin
    dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
    dashboard_page.opt_out(@driver)
    cal_net_page.logout_conf_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    splash_page.load_page(@driver)
    splash_page.click_sign_in_button(@driver)
    cal_net_page.login_admin
    dashboard_page.connect_bconnected_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
  end
end