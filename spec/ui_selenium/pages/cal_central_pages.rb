require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'
require_relative '../util/user_utils'

module CalCentralPages

  include PageObject
  include ClassLogger

  # Header
  link(:my_dashboard_link, :text => 'My Dashboard')
  link(:my_academics_link, :text => 'My Academics')
  link(:my_campus_link, :text => 'My Campus')
  link(:my_finances_link, :text => 'My Finances')

  # Email Badge
  button(:email_badge, :xpath => '//button[@title="bMail"]')
  div(:email_count, :xpath => '//button[@title="bMail"]/div[@data-ng-bind="badge.count"]')
  h4(:unread_email_heading, :xpath => '//h4[text()="Unread bMail Messages"]')
  link(:email_one_link, :xpath => '//button[@title="bMail"]/following-sibling::div//a[@data-ng-href="http://bmail.berkeley.edu/"]')
  div(:email_one_sender, :xpath => '//button[@title="bMail"]/following-sibling::div//div[@data-ng-bind="item.editor"]')
  span(:email_one_subject, :xpath => '//button[@title="bMail"]/following-sibling::div//span[@data-ng-bind="item.title"]')
  span(:email_one_summary, :xpath => '//button[@title="bMail"]/following-sibling::div//span[@data-ng-bind="item.summary"]')

  # Status Popover
  list_item(:status_loading, :xpath => '//li[@data-ng-show="statusLoading"]')
  button(:status_icon, :xpath => '//button[@title="Show your status"]')
  span(:status_alert_count, :xpath => '//span[@data-ng-if="hasAlerts"]/span[@data-ng-bind="count"]')
  h4(:status_popover_heading, :xpath => '//div[@class="cc-popover-title"]/h4')
  div(:no_status_alert, :xpath => '//div[@class="cc-popover-noitems ng-scope"]')
  image(:no_status_alert_icon, :xpath => '//div[@class="cc-popover-noitems ng-scope"]/i[@class="cc-left fa fa-check-circle cc-icon-green"]')
  div(:reg_status_alert, :xpath => '//li[@data-ng-if="studentInfo.regStatus.needsAction && api.user.profile.features.regstatus"]//div')
  link(:reg_status_alert_link, :xpath => '//li[@data-ng-if="studentInfo.regStatus.needsAction && api.user.profile.features.regstatus"]/a')
  image(:reg_status_alert_icon, :xpath => '//li[@data-ng-if="studentInfo.regStatus.needsAction && api.user.profile.features.regstatus"]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')
  div(:block_status_alert, :xpath => '//li[@data-ng-if="studentInfo.regBlock.needsAction || studentInfo.regBlock.errored"]//div')
  span(:block_status_alert_number, :xpath => '//li[@data-ng-if="studentInfo.regBlock.needsAction || studentInfo.regBlock.errored"]//span[@data-ng-bind="studentInfo.regBlock.activeBlocks"]')
  link(:block_status_alert_link, :xpath => '//li[@data-ng-if="studentInfo.regBlock.needsAction || studentInfo.regBlock.errored"]//a')
  image(:block_status_alert_icon, :xpath => '//li[@data-ng-if="studentInfo.regBlock.needsAction || studentInfo.regBlock.errored"]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')
  div(:amount_due_status_alert, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//div')
  link(:amount_due_status_alert_link, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//a')
  image(:amount_due_status_alert_icon, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//i[@class="cc-left fa fa-exclamation-triangle cc-icon-gold"]')
  image(:amount_overdue_status_alert_icon, :xpath => '//li[@data-ng-if="minimumAmountDue && minimumAmountDue > 0"]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')

  # Settings, Log Out
  link(:gear_link, :xpath => '//i[@class="fa fa-cog"]')
  button(:settings_link, :xpath => '//button[@data-ng-click="api.popover.clickThrough(\'Gear - Settings\');api.util.redirect(\'settings\')"]')
  button(:logout_link, :xpath => '//button[contains(text(),"Log out")]')

  # Footer
  div(:toggle_footer_link, :xpath => '//div[@class=\'cc-footer-berkeley\']')
  button(:opt_out_button, :xpath => '//button[text()="Opt out of CalCentral"]')
  button(:opt_out_yes, :xpath => '//button[text()="Yes"]')
  button(:out_out_no, :xpath => '//button[text()="No"]')
  text_field(:basic_auth_uid_input, :name => 'email')
  text_field(:basic_auth_password_input, :name => 'password')
  button(:basic_auth_login_button, :xpath => '//button[contains(text(),"Login")]')

  def click_my_dashboard_link
    logger.info('Clicking My Dashboard link')
    my_dashboard_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_dashboard_link
  end

  def click_my_academics_link
    logger.info('Clicking My Academics link')
    my_academics_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_academics_link
  end

  def click_my_campus_link
    logger.info('Clicking My Campus link')
    my_campus_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_campus_link
  end

  def click_my_finances_link
    logger.info('Clicking My Finances link')
    my_finances_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_finances_link
  end

  def click_email_badge
    logger.info('Clicking email badge on Dashboard')
    email_badge_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    email_badge
  end

  def show_unread_email
    if !unread_email_heading_element.visible?
      email_badge
      unread_email_heading_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    end
  end

  def wait_for_status_popover
    if status_loading_element.visible?
      status_loading_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
    end
  end

  def open_status_popover
    status_icon_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    unless status_popover_heading_element.visible?
      status_icon
    end
  end

  def click_reg_status_alert
    reg_status_alert_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    reg_status_alert_link
  end

  def click_block_status_alert
    block_status_alert_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    block_status_alert_link
  end

  def click_settings_link
    logger.info('Clicking the link to the Settings page')
    gear_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    gear_link
    settings_link
  end

  def click_logout_link
    logger.info('Logging out of CalCentral')
    gear_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    gear_link
    logout_link
  end

  def opt_out(driver)
    logger.info('Opting out of CalCentral')
    toggle_footer_link_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    driver.find_element(:xpath, '//div[@class=\'cc-footer-berkeley\']').click
    opt_out_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    opt_out_button
    opt_out_yes_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    opt_out_yes
  end

  def basic_auth(driver, uid)
    logger.info('Logging in using basic auth')
    toggle_footer_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    driver.find_element(:xpath, '//div[@class=\'cc-footer-berkeley\']').click
    basic_auth_uid_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    self.basic_auth_uid_input = uid
    self.basic_auth_password_input = UserUtils.basic_auth_pass
    basic_auth_login_button
    basic_auth_uid_input_element.when_not_present(timeout=WebDriverUtils.page_load_timeout)
  end

end
