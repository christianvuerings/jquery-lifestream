require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class CanvasPage

  include PageObject
  include ClassLogger

  # Login messages
  h2(:updated_terms_heading, :xpath => '//h2[contains(text(),"Updated Terms of Use")]')
  checkbox(:terms_cbx, :name => 'user[terms_of_use]')
  button(:accept_course_invite, :name => 'accept')
  h2(:recent_activity_heading, :xpath => '//h2[contains(text(),"Recent Activity")]')

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
  link(:delete_course_link, :class => 'delete_course_link')
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

  # Discussions
  link(:new_discussion_link, :id => 'new-discussion-btn')
  text_area(:discussion_title, :id => 'discussion-title')
  checkbox(:threaded_discussion_cbx, :id => 'threaded')
  checkbox(:graded_discussion_cbx, :id => 'use_for_grading')
  elements(:discussion_reply, :list_item, :xpath => '//ul[@class="discussion-entries"]/li')
  link(:primary_reply_link, :xpath => '//article[@id="discussion_topic"]//a[@data-event="addReply"]')
  link(:primary_html_editor_link, :xpath => '//article[@id="discussion_topic"]//a[contains(.,"HTML Editor")]')
  text_area(:primary_reply_input, :xpath => '//article[@id="discussion_topic"]//textarea[@class="reply-textarea"]')
  button(:primary_post_reply_button, :xpath => '//article[@id="discussion_topic"]//button[contains(.,"Post Reply")]')

  # Assignments
  link(:new_assignment_link, :text => 'Assignment')
  select_list(:assignment_type, :id => 'assignment_submission_type')
  text_area(:assignment_name, :id => 'assignment_name')
  text_area(:assignment_due_date, :class => 'DueDateInput')
  checkbox(:text_entry_cbx, :id => 'assignment_text_entry')
  h1(:assignment_title_heading, :class => 'title')
  link(:submit_assignment_link, :text => 'Submit Assignment')

  link(:assignment_file_upload_tab, :class => 'submit_online_upload_option')
  text_area(:file_upload_input, :name => 'attachments[0][uploaded_data]')
  button(:file_upload_submit_button, :id => 'submit_file_button')

  div(:assignment_submission_conf, :xpath => '//div[contains(.,"Turned In!")]')

  button(:publish_button, :class => 'btn-publish')
  button(:save_and_publish_button, :class => 'save_and_publish')
  button(:published_button, :class => 'btn-published')
  button(:submit_button, :xpath => '//button[contains(.,"Submit")]')
  link(:logout_link, :text => 'Logout')

  def load_homepage
    logger.info 'Loading Canvas homepage'
    navigate_to "#{WebDriverUtils.canvas_base_url}"
  end

  def accept_login_messages(course_id)
    wait_until(timeout=WebDriverUtils.page_load_timeout) { current_url.include? "#{course_id}" }
    if updated_terms_heading?
      logger.info 'Accepting terms and conditions'
      terms_cbx_element.when_visible timeout=WebDriverUtils.page_event_timeout
      check_terms_cbx
      submit_button
    end
    recent_activity_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
    if accept_course_invite?
      logger.info 'Accepting course invite'
      accept_course_invite
      accept_course_invite_element.when_not_visible timeout=WebDriverUtils.page_load_timeout
    end
  end

  def log_out(driver)
    driver.switch_to.default_content
    WebDriverUtils.wait_for_element_and_click logout_link_element
  end

  # COURSE SITE SETUP

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

  def create_course_site(current_term, site_name)
    logger.info "Creating a course site named #{site_name}"
    load_sub_account
    WebDriverUtils.wait_for_page_and_click add_new_course_button_element
    course_name_input_element.when_visible timeout=WebDriverUtils.page_event_timeout
    self.course_name_input = "#{site_name}"
    self.ref_code_input = "#{site_name}"
    WebDriverUtils.wait_for_element_and_select(term_element, current_term)
    WebDriverUtils.wait_for_element_and_click create_course_button_element
    add_course_success_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  def search_for_course(test_id)
    tries ||= 10
    logger.info('Searching for course site')
    load_sub_account
    search_course_input_element.when_visible timeout=WebDriverUtils.page_event_timeout
    self.search_course_input = "#{test_id}"
    search_course_button
    wait_until(timeout) { course_site_heading.include? "#{test_id}" }
  rescue => e
    logger.warn 'Course site not found, retrying'
    retry unless (tries -= 1).zero?
  end

  def publish_course(test_id)
    logger.info 'Publishing the course'
    search_for_course test_id
    WebDriverUtils.wait_for_element_and_click publish_button_element
    published_button_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info "Course site URL is #{current_url}"
    current_url.sub("#{WebDriverUtils.canvas_base_url}/courses/", '')
  end

  def add_users(course_id, test_users)
    load_users_page course_id
    test_users.each do |user|
      user_role = user['canvasRole']
      logger.info "Adding UID #{user['uid']} as a course site member with role #{user_role}"
      WebDriverUtils.wait_for_page_and_click add_people_button_element.when_visible
      user_list_element.when_visible timeout=WebDriverUtils.page_event_timeout
      self.user_list = user['uid']
      self.user_role = user_role
      next_button
      WebDriverUtils.wait_for_page_and_click add_button_element
      add_users_success_element.when_visible timeout=WebDriverUtils.page_load_timeout
      done_button
    end
  end

  def create_published_test_course(driver, current_term, site_name, test_users, test_id)
    load_homepage
    create_course_site(current_term, site_name)
    course_id = publish_course test_id
    logger.info "Course ID is #{course_id}"
    add_users(course_id, test_users)
    load_course_site course_id
    log_out driver
    course_id
  end

  def delete_course(course_id)
    logger.info "Deleting course id #{course_id}"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/settings"
    WebDriverUtils.wait_for_page_and_click delete_course_link_element
    WebDriverUtils.wait_for_page_and_click delete_course_button_element
    delete_course_success_element.when_visible timeout=WebDriverUtils.page_load_timeout
  end

  # ANNOUNCEMENTS


  # DISCUSSIONS

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

  def add_reply(discussion_url, reply_body)
    navigate_to discussion_url
    logger.info 'Replying to discussion topic'
    WebDriverUtils.wait_for_page_and_click primary_reply_link_element
    primary_html_editor_link if primary_html_editor_link_element.visible?
    WebDriverUtils.wait_for_element_and_type(primary_reply_input_element, reply_body)
    replies = discussion_reply_elements.length
    primary_post_reply_button
    wait_until(timeout=WebDriverUtils.page_event_timeout) { discussion_reply_elements.length == replies + 1 }
  end

  # ASSIGNMENTS

  def create_assignment(course_id, assignment_name, due_date)
    logger.info "Creating submission assignment named '#{assignment_name}'"
    navigate_to "#{WebDriverUtils.canvas_base_url}/courses/#{course_id}/assignments"
    WebDriverUtils.wait_for_page_and_click new_assignment_link_element
    WebDriverUtils.wait_for_element_and_type(assignment_name_element, assignment_name)
    assignment_type_element.when_visible timeout=WebDriverUtils.page_load_timeout
    self.assignment_type = 'Online'
    text_entry_cbx_element.when_visible timeout=WebDriverUtils.page_event_timeout
    check_text_entry_cbx
    WebDriverUtils.wait_for_element_and_type(assignment_due_date_element, WebDriverUtils.ui_date_input_format(due_date))
    WebDriverUtils.wait_for_element_and_click save_and_publish_button_element
    published_button_element.when_visible timeout=WebDriverUtils.page_load_timeout
    logger.info "Submission assignment URL is #{current_url}"
    current_url
  end

  def submit_assignment(assignment_url, user)
    logger.info "Submitting #{user['testData']} for #{user['username']}"
    navigate_to assignment_url
    WebDriverUtils.wait_for_page_and_click submit_assignment_link_element
    case user['submissionType']
      when 'File'
        file_upload_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        self.file_upload_input_element.send_keys WebDriverUtils.test_data_file_path(user['testData'])
        WebDriverUtils.wait_for_element_and_click file_upload_submit_button_element
      when 'Link'
        WebDriverUtils.wait_for_page_and_click assignment_site_url_tab_element
        url_upload_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        self.url_upload_input = user['testData']
        WebDriverUtils.wait_for_element_and_click url_upload_submit_button_element
      else
        logger.error 'Unsupported submission type in test data'
    end
    assignment_submission_conf_element.when_visible timeout=WebDriverUtils.file_upload_wait
  end

end
