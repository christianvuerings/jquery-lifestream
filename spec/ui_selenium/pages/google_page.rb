require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class GooglePage

  include PageObject
  include ClassLogger

  # LOGIN / LOGOUT
  link(:remove_account_link, :id => 'remove-link')
  text_field(:username_input, :id => 'Email')
  text_field(:password_input, :id => 'Passwd')
  button(:sign_in_button, :id => 'signIn')
  checkbox(:stay_signed_in, :id => 'PersistentCookie')
  link(:sign_out_link, :text => 'Sign out')

  # CONNECT TO CALCENTRAL
  button(:approve_access_button, :id => 'submit_approve_access')
  div(:auth_mail, :xpath => '//div[text()="View and manage your mail"]')
  div(:auth_address, :xpath => '//div[text()="View your email address"]')
  div(:auth_profile, :xpath => '//div[text()="View your basic profile info"]')
  div(:auth_calendar, :xpath => '//div[text()="Manage your calendars"]')
  div(:auth_drive, :xpath => '//div[text()="View metadata for files and documents in your Google Drive"]')
  div(:auth_tasks, :xpath => '//div[text()="Manage your tasks"]')

  # EMAIL
  button(:compose_email_button, :xpath => '//div[text()="COMPOSE"]')
  link(:new_message_heading, :xpath => '//h2[contains(.,"New Message")]')
  link(:recipient, :xpath => 'div[text()="Recipients"]')
  text_area(:to, :xpath => '//textarea[@aria-label="To"]')
  text_area(:subject, :name => 'subjectbox')
  button(:send_email_button, :xpath => '//div[text()="Send"]')
  link(:mail_sent_link, :id => "link_vsm")

  # CALENDAR
  button(:create_event_button, :xpath => '//div[]text()="Create"')
  text_area(:event_title, :xpath => '//input[@title="Event title"]')
  text_area(:event_start_date, :xpath => '//input[@title="From date"]')
  text_area(:event_start_time, :xpath => '//input[@title="From time"]')
  text_area(:event_end_time, :xpath => '//input[@title="Until time"]')
  text_area(:event_end_date, :xpath => '//input[@title="Until date"]')
  text_area(:guest, :xpath => '//input[@title="Enter email addresses"]')
  button(:add_guest, :xpath => '//div[text()="Add"]')
  button(:save_event, :xpath => '//div[text()="Save"]')
  button(:send_no_invites, :name => 'no')
  div(:event_added, :xpath => '//div[contains(text(),"Added"]')

  # TASKS
  button(:toggle_tasks_visibility, :xpath => '//div[@title="Tasks"]')
  h2(:tasks_heading, :xpath => '//h2[contains(.,"Tasks")]')
  link(:add_task, :xpath => '//div[@title="Add task"]')
  text_area(:task_one_title_input, :xpath => '//tr//div[@contenteditable]')
  link(:edit_task_details, :xpath => '//td[@title="Edit Details"]')
  link(:back_to_tasks, :xpath => '//span[contains(.,"Back to list")]')

  def connect_calcentral_to_google(driver, gmail_user, gmail_pass)
    logger.info('Connecting Google account to CalCentral')
    driver.get(WebDriverUtils.base_url + WebDriverUtils.google_auth_url)
    log_into_google(gmail_user, gmail_pass)
    if driver.current_url.include? 'oauth2'
      logger.info('Google permissions page loaded as expected')
      wait_until(timeout=WebDriverUtils.page_load_timeout, 'Auth page does not include expected content') { auth_mail_element.present? }
      wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_event_timeout)
      wait.until { auth_address_element.present? }
      wait.until { auth_profile_element.present? }
      wait.until { auth_calendar_element.present? }
      wait.until { auth_drive_element.present? }
      wait.until { auth_tasks_element.present? }
      wait.until { approve_access_button_element.present? }
      wait.until { approve_access_button_element.enabled? }
      approve_access_button
    else
      logger.warn('Google permissions page did not load')
    end
  end

  def load_gmail(driver)
    logger.info('Loading Gmail')
    driver.get('https://mail.google.com')
  end

  def load_calendar(driver)
    logger.info('Loading Google calendar')
    driver.get('https://calendar.google.com')
  end

  def log_into_google(gmail_user, gmail_pass)
    logger.info('Logging into Google')
    if remove_account_link_element.visible?
      remove_account_link
    end
    username_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    self.username_input = gmail_user
    self.password_input = gmail_pass
    if stay_signed_in_element.exists?
      uncheck_stay_signed_in
    end
    sign_in_button
  end

  def log_out_google(driver, gmail_user)
    logger.info('Logging out of Google')
    driver.find_element(:xpath, '//a[contains(@title,"' + gmail_user + '")]').click
    sign_out_link_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    sign_out_link
  end

  def send_email(driver, recipient, subject, body)
    logger.info('Sending an email with the subject ' + subject)
    compose_email_button_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    compose_email_button
    new_message_heading_element.when_present(timeout=WebDriverUtils.page_event_timeout)
    new_message_heading
    new_message_heading
    if self.recipient_element.visible?
      self.recipient
    end
    to_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    self.to = recipient
    self.subject = subject
    driver.switch_to.frame driver.find_element(:xpath, '//div[@aria-label="Message Body"]/iframe')
    driver.find_element(:xpath, '//body').send_keys body
    driver.switch_to.default_content
    send_email_button
    mail_sent_link_element.when_present(timeout=WebDriverUtils.page_event_timeout)
  end

  def send_invite(driver, event, invitee)
    logger.info('Creating event with the subject ' + event)
    create_event_button_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    create_event_button
    event_title_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    self.event_title = event
    self.guest = invitee
    add_guest
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_event_timeout)
    wait.until { driver.find_element(:xpath, '//div[contains(@title,' + invitee + ')]') }
    save_event
    send_no_invites_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    send_no_invites
    event_added_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
  end

  def create_unsched_task(driver, title)
    logger.info('Creating task with title "' + title + '"')
    toggle_tasks_visibility_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    if !tasks_heading_element.visible?
      toggle_tasks_visibility
      tasks_heading_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    end
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_event_timeout)
    wait.until { driver.find_element(:xpath, '//h2[contains(.,"Tasks")]/following-sibling::div//iframe') }
    driver.switch_to.frame driver.find_element(:xpath, '//h2[contains(.,"Tasks")]/following-sibling::div//iframe')
    add_task_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    add_task
    wait_until(timeout=WebDriverUtils.page_event_timeout, nil) { task_one_title_input == nil }
    self.task_one_title_input = title
    edit_task_details
    sleep(WebDriverUtils.google_task_timeout)
    back_to_tasks
    driver.switch_to.default_content
    toggle_tasks_visibility
  end
end
