require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_to_do_card'
require_relative 'pages/my_academics_page'
require_relative 'pages/my_campus_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_landing_page'

describe 'Logging in with deep linking', :testui => true do

  if ENV["UI_TEST"]

    user = UserUtils.oski_username
    password = UserUtils.oski_password

    before(:each) do
      @driver = WebDriverUtils.driver
    end

    after(:each) do
      @driver.quit
    end

    it 'works for My Dashboard' do
      my_dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
      my_dashboard_page.load_page(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(user, password)
      my_dashboard_page.recent_activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      my_dashboard_page.wait_for_expected_title?
    end

    it 'works for My Academics' do
      my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
      my_academics_page.load_page(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(user, password)
      my_academics_page.page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      my_academics_page.wait_for_expected_title?
      my_academics_page.click_first_student_semester
      semester_page = @driver.current_url
      my_academics_page.click_logout_link
      cal_net_auth_page.logout_conf_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      @driver.get(semester_page)
      cal_net_auth_page.login(user, password)
      @driver.current_url.should eql(semester_page)
    end

    it 'works for My Campus' do
      my_campus_page = CalCentralPages::MyCampusPage.new(@driver)
      my_campus_page.load_page(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(user, password)
      my_campus_page.academic_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      my_campus_page.wait_for_expected_title?
    end

    it 'works for My Finances landing page' do
      my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new(@driver)
      my_finances_page.load_page(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(user, password)
      my_finances_page.page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      my_finances_page.wait_for_expected_title?
    end

  end
end
