require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/canvas_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_classes_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_recent_activity_card'

describe 'My Dashboard', :testui => true, :order => :defined do

  if ENV["UI_TEST"]

    include ClassLogger

    test_id = Time.now.to_i.to_s
    timeout = WebDriverUtils.page_load_timeout
    site_name = "QA WebDriver Test - Canvas Course Site - #{test_id}"
    course_site_members = UserUtils.load_test_users.select { |user| user['recentActivity'] }
    teacher = course_site_members.find { |user| user['canvasRole'] == 'Teacher' }
    student = course_site_members.find { |user| user['canvasRole'] == 'Student' }

    before(:all) do
      @driver = WebDriverUtils.launch_browser

      # Create course site in the current term
      @splash_page = CalCentralPages::SplashPage.new @driver
      @splash_page.load_page @driver
      @splash_page.click_sign_in_button
      @cal_net = CalNetAuthPage.new @driver
      @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
      @my_dashboard = CalCentralPages::MyDashboardRecentActivityCard.new @driver
      @my_dashboard.activity_heading_element.when_visible timeout
      classes_api = ApiMyClassesPage.new @driver
      classes_api.get_json @driver
      current_term = classes_api.current_term
      @canvas = CanvasPage.new @driver
      @course_id = @canvas.create_published_test_course(@driver, current_term, site_name, course_site_members, test_id)

      ######### CREATE PROJECT SITE HERE #########

      @my_dashboard.load_page @driver
      @my_dashboard.click_logout_link
      @splash_page.sign_in_element.when_visible timeout

      # Student accepts course invite so that any new activity will be in the user's feed
      @canvas.load_homepage
      @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
      @canvas.load_course_site @course_id
      @canvas.log_out @driver
      @cal_net.logout_conf_heading_element.when_visible timeout
    end

    describe 'Canvas course assignments' do

      before(:all) do
        # Teacher creates assignment activity
        @canvas.load_homepage
        @cal_net.login("test-#{teacher['uid']}", UserUtils.test_password)
        @canvas.load_course_site @course_id

        @past_assignment_title = "Yesterday Assignment #{@course_id}"
        @past_assignment_due_date = Date.yesterday
        @past_assignment_url = @canvas.create_assignment(@course_id, @past_assignment_title, @past_assignment_due_date)

        @current_assignment_title = "Today Assignment #{@course_id}"
        @current_assignment_due_date = Date.today
        @current_assignment_url = @canvas.create_assignment(@course_id, @current_assignment_title, @current_assignment_due_date)

        @future_assignment_title = "Tomorrow Assignment #{@course_id}"
        @future_assignment_due_date = Date.tomorrow
        @future_assignment_url = @canvas.create_assignment(@course_id, @future_assignment_title, @future_assignment_due_date)

        @canvas.log_out @driver
        @cal_net.logout_conf_heading_element.when_visible timeout

        # Clear cache so that new activity will load immediately
        @splash_page.load_page @driver
        @splash_page.basic_auth(@driver, UserUtils.admin_uid)
        UserUtils.clear_cache @driver
        @my_dashboard.load_page @driver
        @my_dashboard.click_logout_link

        # Student views new activity
        sleep WebDriverUtils.canvas_update_timeout
        @splash_page.load_page @driver
        @splash_page.click_sign_in_button
        @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
        @my_dashboard.wait_for_recent_activity
      end

      context 'when viewed on Recent Activity' do

        before(:all) do

          @activity_summaries = []
          @activity_summaries << 'Assignment Created' << 'Assignment Created' << 'Assignment Created'

          @activity_descriptions = []
          @activity_descriptions << "#{@future_assignment_title}, #{site_name} - A new assignment has been created for your course, #{site_name} #{@future_assignment_title} due: #{@future_assignment_due_date.strftime("%b %e")} at 1159pm"
          @activity_descriptions << "#{@current_assignment_title}, #{site_name} - A new assignment has been created for your course, #{site_name} #{@current_assignment_title} due: #{@current_assignment_due_date.strftime("%b %e")} at 1159pm"
          @activity_descriptions << "#{@past_assignment_title}, #{site_name} - A new assignment has been created for your course, #{site_name} #{@past_assignment_title} due: #{@past_assignment_due_date.strftime("%b %e")} at 1159pm"

          @assignment_urls = []
          @assignment_urls << @future_assignment_url << @current_assignment_url << @past_assignment_url
          @assignment_urls.each { |url| url.sub(WebDriverUtils.canvas_base_url, '') }

        end

        it 'display the course in the activity drop-down' do
          @my_dashboard.wait_for_course_activity(@driver, site_name)
        end

        it 'display a combined notification for similar activity on the same course site on the same date' do
          @my_dashboard.wait_until(timeout) { @my_dashboard.activity_item_summary_elements[0].text == '3 Assignments' }
        end

        it 'display the course site name and date of the activity' do
          @my_dashboard.wait_until(timeout) { @my_dashboard.activity_item_desc_elements[0].text.include? "#{site_name}, #{Date.today.strftime("%b %e")}" }
        end

        it 'display individual assignment activity if a combined notification is expanded' do
          expect(@my_dashboard.all_sub_activity_summaries(@driver, 1)).to eql(@activity_summaries)
        end

        it 'shows a student overdue, current, and future assignment activity detail if a combined notification is expanded' do
          expect(@my_dashboard.all_sub_activity_descriptions(@driver, 1).sort).to eql(@activity_descriptions.sort)
        end

        it 'shows a student overdue, current, and future assignment activity "More info" links if a combined notification is expanded' do
          expect(@my_dashboard.all_sub_activity_info_links(@driver, 1).sort).to eql(@assignment_urls.sort)
        end

      end

      describe 'tasks' do

        #   verify all the tasks on To Do

      end

      describe 'projects' do

        #   verify the project site on My Groups

      end

        after(:all) do
          @cal_net.logout
          @canvas.load_homepage
          @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
          @canvas.delete_course @course_id
        #   delete project site too
        end
    end

    after(:all) { WebDriverUtils.quit_browser @driver }

  end
end
