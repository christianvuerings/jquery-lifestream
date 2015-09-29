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
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_my_classes_card'
require_relative 'pages/my_dashboard_recent_activity_card'
require_relative 'pages/my_dashboard_to_do_card'
require_relative 'pages/api_my_classes_page'

describe 'My Dashboard', :testui => true, :order => :defined do

  if ENV["UI_TEST"]

    include ClassLogger

    test_id = Time.now.to_i.to_s
    timeout = WebDriverUtils.page_load_timeout
    site_name = "QA WebDriver Test - Canvas Course Site - #{test_id}"
    site_descrip = "QA #{test_id} LEC001"
    course_site_members = UserUtils.load_test_users.select { |user| user['canvasIntegration'] }
    teacher = course_site_members.find { |user| user['canvasRole'] == 'Teacher' }
    student = course_site_members.find { |user| user['canvasRole'] == 'Student' }

    before(:all) do
      @driver = WebDriverUtils.launch_browser
      @cal_net = CalNetAuthPage.new @driver
      @canvas = CanvasPage.new @driver
      @recent_activity_card = CalCentralPages::MyDashboardRecentActivityCard.new @driver
      @my_classes_card = CalCentralPages::MyDashboardMyClassesCard.new @driver
      @to_do_card = CalCentralPages::MyDashboardToDoCard.new(@driver)
    end

    describe 'Canvas assignments' do

      before(:all) do
        # Admin creates course site in the current term
        @splash_page = CalCentralPages::SplashPage.new @driver
        @splash_page.load_page @driver
        @splash_page.click_sign_in_button
        @cal_net = CalNetAuthPage.new @driver
        @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
        @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
        @my_classes_card = CalCentralPages::MyDashboardMyClassesCard.new @driver
        @recent_activity_card = CalCentralPages::MyDashboardRecentActivityCard.new @driver
        @my_dashboard.recent_activity_heading_element.when_visible timeout
        classes_api = ApiMyClassesPage.new @driver
        current_term = classes_api.current_term @driver
        @canvas = CanvasPage.new @driver
        @canvas.create_course_site(current_term, site_descrip, site_name)
        @course_id = @canvas.search_for_course test_id
        @canvas.publish_course @course_id
        @canvas.add_users(@course_id, course_site_members)
        @canvas.log_out @driver
        @cal_net.logout_conf_heading_element.when_visible timeout
        @my_dashboard.load_page @driver
        @my_dashboard.click_logout_link
        @splash_page.sign_in_element.when_visible timeout

        # Student accepts course invite so that the site will be included in the user's data
        @canvas.load_homepage
        @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
        @canvas.recent_activity_heading_element.when_visible timeout
        @canvas.load_course_site @course_id
        @canvas.log_out @driver
        @cal_net.logout_conf_heading_element.when_visible timeout

        # Teacher accepts course invite and creates overdue, current, and future assignments
        @canvas.load_homepage
        @cal_net.login("test-#{teacher['uid']}", UserUtils.test_password)
        @canvas.recent_activity_heading_element.when_visible timeout
        @canvas.load_course_site @course_id
        @past_assignment_title = "Yesterday Assignment #{test_id}"
        @past_assignment_due_date = Date.yesterday
        @past_assignment_url = @canvas.create_assignment(@course_id, @past_assignment_title, @past_assignment_due_date)
        @current_assignment_title = "Today Assignment #{test_id}"
        @current_assignment_due_date = Date.today
        @current_assignment_url = @canvas.create_assignment(@course_id, @current_assignment_title, @current_assignment_due_date)
        @future_assignment_title = "Tomorrow Assignment #{test_id}"
        @future_assignment_due_date = Date.tomorrow
        @future_assignment_url = @canvas.create_assignment(@course_id, @future_assignment_title, @future_assignment_due_date)
        @canvas.log_out @driver
        @cal_net.logout_conf_heading_element.when_visible timeout

        # The ordering of the Canvas sub-activities is unpredictable, so compare sorted arrays of the expected and actual assignment data displayed
        @activity_summaries = []
        @activity_summaries << 'Assignment Created' << 'Assignment Created' << 'Assignment Created'
        @activity_descriptions = []
        @activity_descriptions << "#{@future_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@future_assignment_title} due: #{@future_assignment_due_date.strftime("%b %-d")} at 11:59pm"
        @activity_descriptions << "#{@current_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@current_assignment_title} due: #{@current_assignment_due_date.strftime("%b %-d")} at 11:59pm"
        @activity_descriptions << "#{@past_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@past_assignment_title} due: #{@past_assignment_due_date.strftime("%b %-d")} at 11:59pm"

        # Wait for Canvas to index new data
        sleep WebDriverUtils.canvas_update_timeout

        # Clear cache so that new data will load immediately
        @splash_page.load_page @driver
        @splash_page.basic_auth(@driver, UserUtils.admin_uid)
        UserUtils.clear_cache @driver
        @my_dashboard.load_page @driver
        @my_dashboard.click_logout_link
      end

      context 'when viewed by an instructor' do

        before(:all) do
          @splash_page.click_sign_in_button
          @cal_net.login("test-#{teacher['uid']}", UserUtils.test_password)
          @recent_activity_card.wait_for_recent_activity
          @my_classes_card.other_sites_div_element.when_visible WebDriverUtils.academics_timeout
          @to_do_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
        end

        # My Classes
        it 'show the course site name in My Classes' do
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'show the course site description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'show a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end

        # Recent Activity - announcement, discussion, assignments
        it 'show the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end
        it 'show a combined Recent Activity notification for similar activity on the same course site on the same date' do
          @recent_activity_card.wait_until(timeout) { @recent_activity_card.activity_item_summary_elements[0].text == '3 Assignments' }
        end
        it 'show an assignment\'s course site name and creation date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_source_elements[0].text).to eql("#{site_name}")
          expect(@recent_activity_card.activity_item_date_elements[0].text).to eql("#{Date.today.strftime("%b %e")}")
        end
        it 'show individual Recent Activity notifications if a combined one is expanded' do
          expect(@recent_activity_card.all_sub_activity_summaries(@driver, 1)).to eql(@activity_summaries)
        end
        it 'show overdue, current, and future assignment activity detail' do
          expect(@recent_activity_card.all_sub_activity_descriptions(@driver, 1).sort).to eql(@activity_descriptions.sort)
        end

        # To Do - assignments
        it 'show no assignment tasks on To Do' do
          expect(@to_do_card.overdue_task_count).to eql('')
          expect(@to_do_card.today_task_count).to eql('')
          expect(@to_do_card.future_task_count).to eql('')
        end

        after(:all) do
          @my_dashboard.click_logout_link
          @splash_page.sign_in_element.when_visible timeout
          @canvas.hard_log_out
          @cal_net.logout_conf_heading_element.when_visible timeout
        end
      end

      context 'when viewed by a student' do

        before(:all) do
          @splash_page.load_page @driver
          @splash_page.click_sign_in_button
          @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
          @recent_activity_card.wait_for_recent_activity
          @my_classes_card.other_sites_div_element.when_visible WebDriverUtils.academics_timeout
          @to_do_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
        end

        # My Classes
        it 'show the course name in My Classes' do
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'show the course description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'show a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end
        it 'show the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end

        # Recent Activity - announcement, discussion, assignments
        it 'show the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end
        it 'show a combined Recent Activity notification for similar activity on the same course site on the same date' do
          @recent_activity_card.wait_until(timeout) { @recent_activity_card.activity_item_summary_elements[0].text == '3 Assignments' }
        end
        it 'show an assignment\'s course site name and creation date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_source_elements[0].text).to eql("#{site_name}")
          expect(@recent_activity_card.activity_item_date_elements[0].text).to eql("#{Date.today.strftime("%b %e")}")
        end
        it 'show individual Recent Activity notifications if a combined one is expanded' do
          expect(@recent_activity_card.all_sub_activity_summaries(@driver, 1)).to eql(@activity_summaries)
        end
        it 'show overdue, current, and future assignment activity detail' do
          expect(@recent_activity_card.all_sub_activity_descriptions(@driver, 1).sort).to eql(@activity_descriptions.sort)
        end

        # To Do - assignments
        it 'show an overdue assignment as an overdue To Do task' do
          expect(@to_do_card.overdue_task_count).to eql('1')
          expect(@to_do_card.overdue_task_one_title).to eql(@past_assignment_title)
        end
        it 'show an overdue assignment\'s course site name on a To Do task' do
          expect(@to_do_card.overdue_task_one_course).to eql(site_name)
        end
        it 'show an overdue assignment\'s due date and time on a To Do task' do
          expect(@to_do_card.overdue_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @past_assignment_due_date)
          expect(@to_do_card.overdue_task_one_time).to eql('11 PM')
        end
        it 'show a link to an overdue Canvas assignment on a To Do task' do
          @to_do_card.toggle_overdue_task_one_detail
          @to_do_card.overdue_task_one_bcourses_link_element.when_visible timeout
          expect(@to_do_card.overdue_task_one_bcourses_link_element.attribute('href')).to eql(@past_assignment_url)
        end
        it 'show a currently due assignment as a Today To Do task' do
          expect(@to_do_card.today_task_count).to eql('1')
          expect(@to_do_card.today_task_one_title).to eql(@current_assignment_title)
        end
        it 'show a currently due assignment\'s course site name on a To Do task' do
          expect(@to_do_card.today_task_one_course).to eql(site_name)
        end
        it 'show a currently due assignment\'s due date and date on a To Do task' do
          expect(@to_do_card.today_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @current_assignment_due_date)
          expect(@to_do_card.today_task_one_time).to eql('11 PM')
        end
        it 'show a link to a currently due Canvas assignment on a To Do task' do
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.today_task_one_bcourses_link_element.when_visible timeout
          expect(@to_do_card.today_task_one_bcourses_link_element.attribute('href')).to eql(@current_assignment_url)
        end
        it 'show a future assignment as a future To Do task' do
          expect(@to_do_card.future_task_count).to eql('1')
          expect(@to_do_card.future_task_one_title).to eql(@future_assignment_title)
        end
        it 'show a future assignment\'s course site name on a To Do task' do
          expect(@to_do_card.future_task_one_course).to eql(site_name)
        end
        it 'show a future assignment\'s due date and time on a To Do task' do
          expect(@to_do_card.future_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @future_assignment_due_date)
          expect(@to_do_card.future_task_one_time).to eql('11 PM')
        end
        it 'show a link to a future due Canvas assignment on a To Do task' do
          @to_do_card.toggle_future_task_one_detail
          @to_do_card.future_task_one_bcourses_link_element.when_visible timeout
          expect(@to_do_card.future_task_one_bcourses_link_element.attribute('href')).to eql(@future_assignment_url)
        end

        after(:all) do
          @my_dashboard.click_logout_link
          @splash_page.sign_in_element.when_visible timeout
          @canvas.hard_log_out
          @cal_net.logout_conf_heading_element.when_visible timeout
        end
      end

      after(:all) do
        @cal_net.logout
        @canvas.load_homepage
        @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
        @canvas.recent_activity_heading_element.when_visible timeout
        @canvas.delete_course @course_id
      end
    end
  end

  after(:all) { WebDriverUtils.quit_browser @driver }

end
