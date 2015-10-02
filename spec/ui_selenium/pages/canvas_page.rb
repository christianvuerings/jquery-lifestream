require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class CanvasPage

  include PageObject
  include ClassLogger

  # Login and messages
  h2(:updated_terms_heading, :xpath => '//h2[contains(text(),"Updated Terms of Use")]')
  checkbox(:terms_cbx, :name => 'user[terms_of_use]')
  button(:accept_course_invite, :name => 'accept')
  li(:user_name, :class => 'user_name')
  paragraph(:not_available, :xpath => '//p[contains(.,"This course has not been published by the instructor yet.")]')
  h2(:recent_activity_heading, :xpath => '//h2[contains(text(),"Recent Activity")]')
  link(:logout_link, :text => 'Logout')
  text_area(:logout_confirm, :xpath => '//input[@value="Log Out"]')

  # Course
  link(:add_new_course_button, :xpath => '//a[contains(.,"Add a New Course")]')
  text_area(:course_name_input, :xpath => '//label[@for="course_name"]/../following-sibling::td/input')
  text_area(:ref_code_input, :id => 'course_course_code')
  select_list(:term, :id => 'course_enrollment_term_id')
  span(:create_course_button, :xpath => '//span[contains(.,"Add Course")]')
  h2(:course_site_heading, :xpath => '//div[@id="course_home_content"]/h2')
  text_area(:search_course_input, :id => 'course_name')
  button(:search_course_button, :xpath => '//input[@id="course_name"]/following-sibling::button')
  li(:add_course_success, :xpath => '//li[contains(.,"successfully added!")]')
  button(:delete_course_button, :xpath => '//button[text()="Delete Course"]')
  li(:delete_course_success, :xpath => '//li[contains(.,"successfully deleted")]')

  # People
  link(:people_link, :text => 'People')
  link(:add_people_button, :id => 'addUsers')
  text_area(:user_list, :id => 'user_list_textarea')
  select_list(:user_role, :id => 'role_id')
  button(:next_button, :id => 'next-step')
  button(:add_button, :id => 'createUsersAddButton')
  paragraph(:add_users_success, :xpath => '//p[contains(.,"The following users have been enrolled")]')
  button(:done_button, :xpath => '//button[contains(.,"Done")]')

  # Announcements
  link(:new_announcement_link, :text => 'Announcement')
  link(:html_editor_link, :xpath => '//a[contains(.,"HTML Editor")]')
  text_area(:announcement_msg, :name => 'message')
  button(:save_announcement_button, :xpath => '//h1[contains(text(),"New Discussion")]/following-sibling::div/button[contains(text(),"Save")]')
  h1(:announcement_title_heading, :class => 'discussion-title')

  # Discussions
  link(:new_discussion_link, :id => 'new-discussion-btn')
  text_area(:discussion_title, :id => 'discussion-title')
  checkbox(:threaded_discussion_cbx, :id => 'threaded')
  checkbox(:graded_discussion_cbx, :id => 'use_for_grading')
  elements(:discussion_reply, :list_item, :xpath => '//ul[@class="discussion-entries"]/li')
  link(:primary_reply_link, :xpath => '//article[@id="discussion_topic"]//a[@data-event="addReply"]')
  link(:primary_html_editor_link, :xpath => '//article[@id="discussion_topic"]//a[contains(.,"HTML Editor")]')

  # Assignments
  link(:new_assignment_link, :text => 'Assignment')
  select_list(:assignment_type, :id => 'assignment_submission_type')
  text_area(:assignment_name, :id => 'assignment_name')
  text_area(:assignment_due_date, :class => 'DueDateInput')
  checkbox(:text_entry_cbx, :id => 'assignment_text_entry')
  h1(:assignment_title_heading, :class => 'title')

  # Generic buttons
  button(:publish_button, :class => 'btn-publish')
  button(:save_and_publish_button, :class => 'save_and_publish')
  button(:published_button, :class => 'btn-published')
  button(:submit_button, :xpath => '//button[contains(.,"Submit")]')

  # NAVIGATION

  def load_homepage
    navigate_to "#{WebDriverUtils.canvas_base_url}"
  end

  def log_in(cal_net_page, username, password)
    load_homepage
    cal_net_page.login(username, password)
    recent_activity_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  def accept_login_messages(course_id)
    wait_until(timeout=WebDriverUtils.page_load_timeout) { current_url.include? "#{course_id}" }
    sleep 1
    if updated_terms_heading?
      logger.info 'Accepting terms and conditions'
      terms_cbx_element.when_visible timeout=WebDriverUtils.page_event_timeout
      check_terms_cbx
      submit_button
    end
    recent_activity_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
    sleep 1
    if accept_course_invite?
      logger.info 'Accepting course invite'
      accept_course_invite
      accept_course_invite_element.when_not_visible timeout=WebDriverUtils.page_load_timeout
    end
  end

  def log_out(cal_net_page)
    navigate_to "#{WebDriverUtils.canvas_base_url}/logout"
    WebDriverUtils.wait_for_page_and_click logout_confirm_element
    cal_net_page.logout_conf_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  def load_sub_account
    navigate_to "#{WebDriverUtils.canvas_base_url}/accounts/#{WebDriverUtils.canvas_qa_sub_account}"
  end

  def load_course_site(course_id)
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}"
    accept_login_messages course_id
  end

  def load_users_page(course_id)
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/users"
  end

  # COURSE SITE SETUP

  def create_course_site(current_term, site_code, site_name)
    logger.info "Creating a course site named #{site_name}"
    load_sub_account
    WebDriverUtils.wait_for_page_and_click add_new_course_button_element
    course_name_input_element.when_visible timeout=WebDriverUtils.page_event_timeout
    self.course_name_input = "#{site_code}"
    self.ref_code_input = "#{site_name}"
    WebDriverUtils.wait_for_element_and_select(term_element, current_term)
    WebDriverUtils.wait_for_element_and_click create_course_button_element
    add_course_success_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  def search_for_course(test_id)
    tries ||= 3
    load_sub_account
    search_course_input_element.when_visible timeout=WebDriverUtils.page_event_timeout
    self.search_course_input = "#{test_id}"
    search_course_button
    wait_until(timeout) { course_site_heading.include? "#{test_id}" }
    logger.info "Course site URL is #{current_url}"
    current_url.sub("#{WebDriverUtils.canvas_base_url}/courses/", '')
  rescue
    retry unless (tries -= 1).zero?
  end

  def publish_course(course_id)
    logger.info 'Publishing the course'
    load_course_site course_id
    WebDriverUtils.wait_for_element_and_click publish_button_element
    published_button_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  def add_users(course_id, test_users)
    test_users.each do |user|
      begin
        # Canvas add-user function is often flaky in test envs, so retry if it fails
        tries ||= 3
        load_users_page course_id
        user_role = user['canvasRole']
        logger.info "Adding UID #{user['uid']} as a course site member with role #{user_role}"
        WebDriverUtils.wait_for_page_and_click add_people_button_element
        user_list_element.when_visible timeout=WebDriverUtils.page_event_timeout
        self.user_list = user['uid']
        self.user_role = user_role
        next_button
        WebDriverUtils.wait_for_page_and_click add_button_element
        add_users_success_element.when_visible timeout
        done_button
      rescue
        logger.warn 'Add User failed, retrying'
        retry unless (tries -=1).zero?
      end
    end
  end

  def create_complete_test_course(current_term, site_code, site_name, test_id, test_users)
    create_course_site(current_term, site_code, site_name)
    course_id = search_for_course test_id
    publish_course course_id
    add_users(course_id, test_users)
    course_id
  end

  def delete_course(course_id)
    logger.info "Deleting course id #{course_id}"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/confirm_action?event=delete"
    WebDriverUtils.wait_for_page_and_click delete_course_button_element
    delete_course_success_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info 'Course site has been deleted.'
  end

  # COURSE ACTIVITY

  def create_announcement(course_id, announcement_title, announcement_body)
    logger.info "Creating announcement: #{announcement_body}"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/announcements"
    WebDriverUtils.wait_for_page_and_click new_announcement_link_element
    WebDriverUtils.wait_for_element_and_type(discussion_title_element, announcement_title)
    html_editor_link if html_editor_link_element.visible?
    WebDriverUtils.wait_for_element_and_type(announcement_msg_element, announcement_body)
    WebDriverUtils.wait_for_element_and_click save_announcement_button_element
    announcement_title_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info "Announcement URL is #{current_url}"
    current_url.gsub!('discussion_topics', 'announcements')
  end

  def create_discussion(course_id, discussion_name)
    logger.info "Creating discussion topic named '#{discussion_name}'"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/discussion_topics"
    WebDriverUtils.wait_for_page_and_click new_discussion_link_element
    WebDriverUtils.wait_for_element_and_type(discussion_title_element, discussion_name)
    check_threaded_discussion_cbx
    WebDriverUtils.wait_for_element_and_click save_and_publish_button_element
    published_button_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info "Discussion URL is #{current_url}"
    current_url
  end

  def create_assignment(course_id, assignment_name, due_date)
    logger.info "Creating submission assignment named '#{assignment_name}'"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/assignments"
    WebDriverUtils.wait_for_page_and_click new_assignment_link_element
    WebDriverUtils.wait_for_element_and_type(assignment_name_element, assignment_name)
    WebDriverUtils.wait_for_element_and_type(assignment_due_date_element, due_date.strftime("%b %-d %Y"))
    sleep 2
    text_entry_cbx_element.when_visible timeout=WebDriverUtils.page_event_timeout
    check_text_entry_cbx
    WebDriverUtils.wait_for_element_and_click save_and_publish_button_element
    published_button_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info "Submission assignment URL is #{current_url}"
    current_url
  end

end
