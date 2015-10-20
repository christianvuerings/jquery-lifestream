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
require_relative 'pages/my_dashboard_notifications_card'
require_relative 'pages/my_dashboard_tasks_card'
require_relative 'pages/api_my_classes_page'

describe 'My Dashboard', :testui => true, :order => :defined do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    test_id = Time.now.to_i.to_s
    timeout = WebDriverUtils.page_load_timeout
    site_name = "QA WebDriver Test - Canvas Course Site - #{test_id}"
    site_descrip = "QA #{test_id} LEC001"
    course_site_members = UserUtils.load_test_users.select { |user| user['canvasIntegration'] }
    teacher = course_site_members.find { |user| user['canvasRole'] == 'Teacher' }
    student = course_site_members.find { |user| user['canvasRole'] == 'Student' }

    before(:all) { @driver = WebDriverUtils.launch_browser }

    describe 'Canvas activities' do

      before(:all) do
        # Admin creates course site in the current term
        @splash_page = CalCentralPages::SplashPage.new @driver
        @splash_page.load_page
        @splash_page.click_sign_in_button
        @cal_net = CalNetAuthPage.new @driver
        @cal_net.login(UserUtils.qa_username, UserUtils.qa_password)
        @my_dashboard = CalCentralPages::MyDashboardPage.new @driver
        @my_classes_card = CalCentralPages::MyDashboardMyClassesCard.new @driver
        @notifications_card = CalCentralPages::MyDashboardNotificationsCard.new @driver
        @tasks_card = CalCentralPages::MyDashboardTasksCard.new(@driver)
        @notifications_card.notifications_heading_element.when_visible timeout
        classes_api = ApiMyClassesPage.new @driver
        classes_api.get_json @driver
        current_term = classes_api.current_term
        @my_dashboard.log_out @splash_page
        @canvas = CanvasPage.new @driver
        @canvas.log_in(@cal_net, UserUtils.qa_username, UserUtils.qa_password)
        @course_id = @canvas.create_complete_test_course(current_term, site_descrip, site_name, test_id, course_site_members)
        @canvas.log_out @cal_net

        # Student accepts course invite so that the site will be included in the user's data
        @canvas.log_in(@cal_net, "test-#{student['uid']}", UserUtils.test_password)
        @canvas.load_course_site @course_id
        @canvas.log_out @cal_net

        # Teacher creates a discussion, an announcement, and past/present/future assignments
        @canvas.log_in(@cal_net, "test-#{teacher['uid']}", UserUtils.test_password)
        @canvas.load_course_site @course_id

        @discussion_title = "Discussion title in #{site_name}"
        @discussion_url = @canvas.create_discussion(@course_id, @discussion_title)

        @announcement_title = "Announcement title in #{site_name}"
        @announcement_body = "This is the body of an announcement about #{site_name}"
        @announcement_url = @canvas.create_announcement(@course_id, @announcement_title, @announcement_body)

        @past_assignment_title = "Yesterday Assignment #{test_id}"
        @past_assignment_due_date = Date.yesterday
        @past_assignment_url = @canvas.create_assignment(@course_id, @past_assignment_title, @past_assignment_due_date)

        @current_assignment_title = "Today Assignment #{test_id}"
        @current_assignment_due_date = Date.today
        @current_assignment_url = @canvas.create_assignment(@course_id, @current_assignment_title, @current_assignment_due_date)

        @future_assignment_title = "Tomorrow Assignment #{test_id}"
        @future_assignment_due_date = Date.tomorrow
        @future_assignment_url = @canvas.create_assignment(@course_id, @future_assignment_title, @future_assignment_due_date)

        # The ordering of the Canvas assignment sub-activities is unpredictable, so compare sorted arrays of the expected and actual assignment data displayed
        @assignment_summaries = []
        @assignment_summaries << 'Assignment Created' << 'Assignment Created' << 'Assignment Created'
        @assignment_descriptions = []
        @assignment_descriptions << "#{@future_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@future_assignment_title} due: #{@future_assignment_due_date.strftime("%b %-d")} at 11:59pm"
        @assignment_descriptions << "#{@current_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@current_assignment_title} due: #{@current_assignment_due_date.strftime("%b %-d")} at 11:59pm"
        @assignment_descriptions << "#{@past_assignment_title}, #{site_descrip} - A new assignment has been created for your course, #{site_descrip} #{@past_assignment_title} due: #{@past_assignment_due_date.strftime("%b %-d")} at 11:59pm"

        @canvas.log_out @cal_net

        # Wait for Canvas to index new data
        sleep WebDriverUtils.canvas_update_timeout

        # Clear cache so that new data will load immediately
        UserUtils.clear_cache(@driver, @splash_page, @my_dashboard)
      end

      context 'when viewed by an instructor' do

        before(:all) do
          @splash_page.click_sign_in_button
          @cal_net.login("test-#{teacher['uid']}", UserUtils.test_password)
          @notifications_card.wait_for_notifications site_name

          # The ordering of the Canvas notifications is unpredictable, so find out which is where on the activities list
          notifications = []
          @notifications_card.notification_summary_elements.each { |summary| notifications << summary.text }
          @discussion_index = notifications.index(notifications.find { |summary| summary.include? 'Discussion' })
          @announcement_index = notifications.index(notifications.find { |summary| summary.include? 'Announcement' })
          @assignment_index = notifications.index(notifications.find { |summary| summary.include? 'Assignment' })
          logger.info "Discussion is at #{@discussion_index.to_s}, Announcement is at #{@announcement_index.to_s}, and Assignments are at #{@assignment_index.to_s}"
        end

        # My Classes
        it 'show the course site name in My Classes' do
          @my_classes_card.other_sites_div_element.when_visible WebDriverUtils.academics_timeout
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'show the course site description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'show a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end

        # Notifications - announcement, discussion
        it 'show a combined notification for similar notifications on the same course site on the same date' do
          @notifications_card.wait_until(timeout) { @notifications_card.notification_summary_elements[@assignment_index].text == '3 Assignments' }
        end
        it 'show an assignment\'s course site name and creation date on a notification' do
          expect(@notifications_card.notification_source_elements[@assignment_index].text).to eql("#{site_name}")
          expect(@notifications_card.notification_date_elements[@assignment_index].text).to eql("#{Date.today.strftime("%b %-d")}")
        end
        it 'show individual notifications if a combined one is expanded' do
          expect(@notifications_card.sub_notification_summaries(@assignment_index)).to eql(@assignment_summaries)
        end
        it 'show overdue, current, and future assignment notification detail' do
          expect(@notifications_card.sub_notification_descrips(@assignment_index).sort).to eql(@assignment_descriptions.sort)
        end
        it 'show an announcement title on a notification' do
          expect(@notifications_card.notification_summary_elements[@announcement_index].text).to eql(@announcement_title)
        end
        it 'show an announcement source on a notification' do
          @notifications_card.expand_notification_detail @announcement_index
          expect(@notifications_card.notification_source_elements[@announcement_index].text).to eql(site_name)
        end
        it 'show an announcement date on a notification' do
          expect(@notifications_card.notification_date_elements[@announcement_index].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'show announcement detail on a notification' do
          expect(@notifications_card.notification_desc_elements[@announcement_index].text).to eql(@announcement_body)
        end
        it 'show a link to an announcement on a notification' do
          expect(@notifications_card.notification_more_info_link(@announcement_index).attribute('href')).to eql(@announcement_url)
        end
        it 'show a discussion title on a notification' do
          expect(@notifications_card.notification_summary_elements[@discussion_index].text).to eql(@discussion_title)
        end
        it 'show a discussion source on a notification' do
          @notifications_card.expand_notification_detail @discussion_index
          expect(@notifications_card.notification_source_elements[@discussion_index].text).to eql(site_name)
        end
        it 'show a discussion date on a notification' do
          expect(@notifications_card.notification_date_elements[@discussion_index].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'show a link to a discussion on a notification' do
          expect(@notifications_card.notification_more_info_link(@discussion_index).attribute('href')).to eql(@discussion_url)
        end

        # Tasks - assignments
        it 'show no assignment tasks' do
          @tasks_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
          expect(@tasks_card.overdue_task_count).to eql('')
          expect(@tasks_card.today_task_count).to eql('')
          expect(@tasks_card.future_task_count).to eql('')
        end

        after(:all) do
          if @notifications_card.notifications_heading?
            @my_dashboard.click_logout_link
            @splash_page.sign_in_element.when_visible timeout
          end
          @canvas.log_out @cal_net
        end
      end

      context 'viewed by a student' do

        before(:all) do
          @splash_page.load_page
          @splash_page.click_sign_in_button
          @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
          @notifications_card.wait_for_notifications site_name

          # The ordering of the Canvas notifications is unpredictable, so find out which is where on the activities list
          notifications = []
          @notifications_card.notification_summary_elements.each { |summary| notifications << summary.text }
          @discussion_index = notifications.index(notifications.find { |summary| summary.include? 'Discussion' })
          @announcement_index = notifications.index(notifications.find { |summary| summary.include? 'Announcement' })
          @assignment_index = notifications.index(notifications.find { |summary| summary.include? 'Assignments' })
          logger.info "Discussion is at #{@discussion_index.to_s}, Announcement is at #{@announcement_index.to_s}, and Assignments are at #{@assignment_index.to_s}"
        end

        # My Classes
        it 'show the course name in My Classes' do
          @my_classes_card.other_sites_div_element.when_visible WebDriverUtils.academics_timeout
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'show the course description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'show a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end

        # Notifications - assignments, announcement, discussion
        it 'show a combined notification for similar notifications on the same course site on the same date' do
          @notifications_card.wait_until(timeout) { @notifications_card.notification_summary_elements[@assignment_index].text == '3 Assignments' }
        end
        it 'show an assignment\'s course site name and creation date on a notification' do
          expect(@notifications_card.notification_source_elements[@assignment_index].text).to eql("#{site_name}")
          expect(@notifications_card.notification_date_elements[@assignment_index].text).to eql("#{Date.today.strftime("%b %-d")}")
        end
        it 'show individual notifications if a combined one is expanded' do
          expect(@notifications_card.sub_notification_summaries(@assignment_index)).to eql(@assignment_summaries)
        end
        it 'show overdue, current, and future assignment notifications detail' do
          expect(@notifications_card.sub_notification_descrips(@assignment_index).sort).to eql(@assignment_descriptions.sort)
        end
        it 'show an announcement title on a notification' do
          expect(@notifications_card.notification_summary_elements[@announcement_index].text).to eql(@announcement_title)
        end
        it 'show an announcement source on a notification' do
          @notifications_card.expand_notification_detail @announcement_index
          expect(@notifications_card.notification_source_elements[@announcement_index].text).to eql(site_name)
        end
        it 'show an announcement date on a notification' do
          expect(@notifications_card.notification_date_elements[@announcement_index].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'show an announcement detail on a notification' do
          expect(@notifications_card.notification_desc_elements[@announcement_index].text).to eql(@announcement_body)
        end
        it 'show a link to an announcement on a notification' do
          expect(@notifications_card.notification_more_info_link(@announcement_index).attribute('href')).to eql(@announcement_url)
        end
        it 'show a discussion title on a notification' do
          expect(@notifications_card.notification_summary_elements[@discussion_index].text).to eql(@discussion_title)
        end
        it 'show a discussion source on a notification' do
          @notifications_card.expand_notification_detail @discussion_index
          expect(@notifications_card.notification_source_elements[@discussion_index].text).to eql(site_name)
        end
        it 'show a discussion date on a notification' do
          expect(@notifications_card.notification_date_elements[@discussion_index].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'show a link to a discussion on a notification' do
          expect(@notifications_card.notification_more_info_link(@discussion_index).attribute('href')).to eql(@discussion_url)
        end

        # Tasks - assignments
        it 'show an overdue assignment as an overdue task' do
          @tasks_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
          expect(@tasks_card.overdue_task_count).to eql('1')
          expect(@tasks_card.overdue_task_one_title).to eql(@past_assignment_title)
        end
        it 'show an overdue assignment\'s course site name on a task' do
          expect(@tasks_card.overdue_task_one_course).to eql(site_name)
        end
        it 'show an overdue assignment\'s due date and time on a task' do
          expect(@tasks_card.overdue_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @past_assignment_due_date)
          expect(@tasks_card.overdue_task_one_time).to eql('11 PM')
        end
        it 'show a link to an overdue Canvas assignment on a task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_toggle_element
          @tasks_card.overdue_task_one_bcourses_link_element.when_visible timeout
          expect(@tasks_card.overdue_task_one_bcourses_link_element.attribute('href')).to eql(@past_assignment_url)
        end
        it 'show a currently due assignment as a Today task' do
          expect(@tasks_card.today_task_count).to eql('1')
          expect(@tasks_card.today_task_one_title).to eql(@current_assignment_title)
        end
        it 'show a currently due assignment\'s course site name on a task' do
          expect(@tasks_card.today_task_one_course).to eql(site_name)
        end
        it 'show a currently due assignment\'s due date and date on a task' do
          expect(@tasks_card.today_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @current_assignment_due_date)
          expect(@tasks_card.today_task_one_time).to eql('11 PM')
        end
        it 'show a link to a currently due Canvas assignment on a task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          @tasks_card.today_task_one_bcourses_link_element.when_visible timeout
          expect(@tasks_card.today_task_one_bcourses_link_element.attribute('href')).to eql(@current_assignment_url)
        end
        it 'show a future assignment as a future task' do
          expect(@tasks_card.future_task_count).to eql('1')
          expect(@tasks_card.future_task_one_title).to eql(@future_assignment_title)
        end
        it 'show a future assignment\'s course site name on a task' do
          expect(@tasks_card.future_task_one_course).to eql(site_name)
        end
        it 'show a future assignment\'s due date and time on a task' do
          expect(@tasks_card.future_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format @future_assignment_due_date)
          expect(@tasks_card.future_task_one_time).to eql('11 PM')
        end
        it 'show a link to a future due Canvas assignment on a task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.future_task_one_toggle_element
          @tasks_card.future_task_one_bcourses_link_element.when_visible timeout
          expect(@tasks_card.future_task_one_bcourses_link_element.attribute('href')).to eql(@future_assignment_url)
        end
      end

      after(:all) do
        @canvas.log_out @cal_net
        @canvas.log_in(@cal_net, UserUtils.qa_username, UserUtils.qa_password)
        @canvas.delete_course @course_id
      end
    end

    after(:all) { WebDriverUtils.quit_browser @driver }

  end
end
