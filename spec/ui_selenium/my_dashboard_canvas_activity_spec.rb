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

    before(:all) { @driver = WebDriverUtils.launch_browser }

    describe 'Canvas activity' do

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

        # Teacher accepts course invite and creates a discussion and an announcement
        @canvas.load_homepage
        @cal_net.login("test-#{teacher['uid']}", UserUtils.test_password)
        @canvas.recent_activity_heading_element.when_visible timeout
        @canvas.load_course_site @course_id
        @discussion_title = "Discussion title in #{site_name}"
        @discussion_url = @canvas.create_discussion(@course_id, @discussion_title)
        @announcement_title = "Announcement title in #{site_name}"
        @announcement_body = "This is the body of an announcement about #{site_name}"
        @announcement_url = @canvas.create_announcement(@course_id, @announcement_title, @announcement_body)
        @canvas.log_out @driver
        @cal_net.logout_conf_heading_element.when_visible timeout

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
        end

        # My Classes
        it 'shows the course site name in My Classes' do
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'shows the course site description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'shows a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end

        # Recent Activity - announcement, discussion
        it 'shows the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end
        it 'shows an announcement title on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_summary_elements[0].text).to eql(@announcement_title)
        end
        it 'shows an announcement source on a Recent Activity item' do
          @recent_activity_card.expand_activity_detail 0
          expect(@recent_activity_card.activity_item_source_elements[0].text).to eql(site_name)
        end
        it 'shows an announcement date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_date_elements[0].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'shows an announcement detail on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_desc_elements[0].text).to eql(@announcement_body)
        end
        it 'shows a link to an announcement on a Recent Activity item' do
          expect(@recent_activity_card.activity_more_info_link_elements[0].attribute('href')).to eql(@announcement_url)
        end
        it 'shows a discussion title on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_summary_elements[1].text).to eql(@discussion_title)
        end
        it 'shows a discussion source on a Recent Activity item' do
          @recent_activity_card.expand_activity_detail 1
          expect(@recent_activity_card.activity_item_source_elements[1].text).to eql(site_name)
        end
        it 'shows a discussion date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_date_elements[1].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end

        after(:all) do
          @my_dashboard.click_logout_link
          @splash_page.sign_in_element.when_visible timeout
          @canvas.hard_log_out
          @cal_net.logout_conf_heading_element.when_visible timeout
        end
      end

      context 'viewed by a student' do

        before(:all) do
          @splash_page.load_page @driver
          @splash_page.click_sign_in_button
          @cal_net.login("test-#{student['uid']}", UserUtils.test_password)
          @recent_activity_card.wait_for_recent_activity
          @my_classes_card.other_sites_div_element.when_visible WebDriverUtils.academics_timeout
        end

        # My Classes
        it 'shows the course name in My Classes' do
          expect(@my_classes_card.other_course_site_names).to include(site_name)
        end
        it 'shows the course description in My Classes' do
          expect(@my_classes_card.other_course_site_descrips).to include(site_descrip)
        end
        it 'shows a link to the course site in My Classes' do
          WebDriverUtils.verify_external_link(@driver, @my_classes_card.other_course_site_link_elements[0], site_descrip)
        end
        it 'shows the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end

        # Recent Activity - announcement, discussion
        it 'shows the course in the Recent Activity drop-down' do
          @recent_activity_card.wait_for_course_activity(@driver, site_name)
        end
        it 'shows an announcement title on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_summary_elements[0].text).to eql(@announcement_title)
        end
        it 'shows an announcement source on a Recent Activity item' do
          @recent_activity_card.expand_activity_detail 0
          expect(@recent_activity_card.activity_item_source_elements[0].text).to eql(site_name)
        end
        it 'shows an announcement date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_date_elements[0].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'shows an announcement detail on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_desc_elements[0].text).to eql(@announcement_body)
        end
        it 'shows a link to an announcement on a Recent Activity item' do
          expect(@recent_activity_card.activity_more_info_link_elements[0].attribute('href')).to eql(@announcement_url)
        end
        it 'shows a discussion title on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_summary_elements[1].text).to eql(@discussion_title)
        end
        it 'shows a discussion source on a Recent Activity item' do
          @recent_activity_card.expand_activity_detail 1
          expect(@recent_activity_card.activity_item_source_elements[1].text).to eql(site_name)
        end
        it 'shows a discussion date on a Recent Activity item' do
          expect(@recent_activity_card.activity_item_date_elements[1].text).to eql(WebDriverUtils.ui_alphanumeric_date_format Date.today)
        end
        it 'shows a link to a discussion on a Recent Activity item' do
          expect(@recent_activity_card.activity_more_info_link_elements[1].attribute('href')).to eql(@discussion_url)
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

    after(:all) { WebDriverUtils.quit_browser @driver }

  end
end
