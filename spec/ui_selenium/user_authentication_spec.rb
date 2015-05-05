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
require_relative 'pages/my_academics_page'
require_relative 'pages/my_campus_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_landing_page'
require_relative 'pages/my_finances_details_page'
require_relative 'pages/settings_page'
require_relative 'pages/google_page'
require_relative 'pages/api_my_academics_page_semesters'

describe 'User authentication', :testui => true do

  if ENV["UI_TEST"]

    before(:each) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:each) do
      WebDriverUtils.quit_browser(@driver)
    end

    before(:example) do
      @cal_net_auth_page = CalNetAuthPage.new(@driver)
    end

    context 'when logging into CalCentral' do

      it 'loads the Dashboard by default' do
        splash_page = CalCentralPages::SplashPage.new(@driver)
        splash_page.load_page(@driver)
        splash_page.click_sign_in_button
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        my_dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
        my_dashboard_page.wait_until(timeout=WebDriverUtils.page_load_timeout) { my_dashboard_page.current_url == "#{WebDriverUtils.base_url}/dashboard" }
      end

    end

    context 'when deep-linking into CalCentral' do

      it 'can take the user to My Dashboard' do
        my_dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
        my_dashboard_page.load_page(@driver)
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        expect(my_dashboard_page.current_url).to eql("#{WebDriverUtils.base_url}/dashboard")
      end

      context 'My Academics pages' do

        it 'can take the user to My Academics' do
          my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
          my_academics_page.load_page(@driver)
          @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
          expect(my_academics_page.current_url).to eql("#{WebDriverUtils.base_url}/academics")
        end

        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.click_sign_in_button
          @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
          academics_api = ApiMyAcademicsPageSemesters.new(@driver)
          academics_api.get_json(@driver)
          semester = academics_api.all_semesters[0]
          @semester_page_path = academics_api.semester_slug(semester)
          @my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
          @my_academics_page.load_page(@driver)
          @my_academics_page.click_logout_link
          splash_page.wait_for_expected_title?
        end

        it 'can take the user to a semester page' do
          @my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
          @my_academics_page.load_semester_page(@driver, @semester_page_path)
          @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
          expect(@my_academics_page.current_url).to eql("#{WebDriverUtils.base_url}/academics/semester/#{@semester_page_path}")
        end

        before(:example) do
          splash_page = CalCentralPages::SplashPage.new(@driver)
          splash_page.load_page(@driver)
          splash_page.click_sign_in_button
          @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
          academics_api = ApiMyAcademicsPageSemesters.new(@driver)
          academics_api.get_json(@driver)
          semester = academics_api.all_semesters[0]
          course = academics_api.semester_courses(semester)[0]
          @class_page_path = academics_api.course_url(course)
          @my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
          @my_academics_page.load_page(@driver)
          @my_academics_page.click_logout_link
          splash_page.wait_for_expected_title?
        end

        it 'can take the user to a class page' do
          @my_academics_page = CalCentralPages::MyAcademicsPage.new(@driver)
          @my_academics_page.load_class_page(@driver, @class_page_path)
          @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
          expect(@my_academics_page.current_url).to eql("#{WebDriverUtils.base_url}#{@class_page_path}")
        end

      end

      it 'can take the user to My Finances' do
        my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new(@driver)
        my_finances_page.load_page(@driver)
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        expect(my_finances_page.current_url).to eql("#{WebDriverUtils.base_url}/finances")
      end

      it 'can take the user to the finances details page' do
        my_finances_details_page = CalCentralPages::MyFinancesPages::MyFinancesDetailsPage.new(@driver)
        my_finances_details_page.load_page(@driver)
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        expect(my_finances_details_page.current_url).to eql("#{WebDriverUtils.base_url}/finances/details")
      end

      it 'can take the user to My Campus' do
        my_campus_page = CalCentralPages::MyCampusPage.new(@driver)
        my_campus_page.load_page(@driver)
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        expect(my_campus_page.current_url).to eql("#{WebDriverUtils.base_url}/campus")
      end

      it 'can take the user to the Settings page' do
        settings_page = CalCentralPages::SettingsPage.new(@driver)
        settings_page.load_page(@driver)
        @cal_net_auth_page.login(UserUtils.oski_username, UserUtils.oski_password)
        expect(settings_page.current_url).to eql("#{WebDriverUtils.base_url}/settings")
      end

    end

    context 'when opting out of CalCentral' do

      before(:example) do
        @splash_page = CalCentralPages::SplashPage.new(@driver)
        @splash_page.load_page(@driver)
        @splash_page.click_sign_in_button
        @cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      end

      it 'logs the user out of CalCentral' do
        dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
        dashboard_page.opt_out(@driver)
        @splash_page.wait_for_expected_title?
        @splash_page.sign_in_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        @splash_page.click_sign_in_button
        @cal_net_auth_page.page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        expect(@cal_net_auth_page.username_element.visible?).to be true
      end

    end
  end
end
