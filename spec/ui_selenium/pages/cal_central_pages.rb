require 'selenium-webdriver'
require 'page-object'

module CalCentralPages

  include PageObject

  # Header
  link(:my_dashboard_link, :text => 'My Dashboard')
  link(:my_academics_link, :text => 'My Academics')
  link(:my_campus_link, :text => 'My Campus')
  link(:my_finances_link, :text => 'My Finances')

  # Settings, Log Out
  link(:gear_link, :xpath => '//i[@class="fa fa-cog"]')
  button(:settings_link, :xpath => '//button[@data-ng-click="api.popover.clickThrough(\'Gear - Settings\');api.util.redirect(\'settings\')"]')
  button(:logout_link, :xpath => '//button[contains(text(),"Log out")]')

  # Footer
  div(:toggle_footer_link, :xpath => '//div[@class=\'cc-footer-berkeley\']')
  button(:opt_out_button, :xpath => '//button[text()="Opt out of CalCentral"]')
  button(:opt_out_yes, :xpath => '//button[text()="Yes"]')
  button(:out_out_no, :xpath => '//button[text()="No"]')

  def click_my_dashboard_link
    my_dashboard_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_dashboard_link
  end

  def click_my_academics_link
    my_academics_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_academics_link
  end

  def click_my_campus_link
    my_campus_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_campus_link
  end

  def click_my_finances_link
    my_finances_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    my_finances_link
  end

  def click_settings_link
    gear_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    gear_link
    settings_link
  end

  def click_logout_link
    gear_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    gear_link
    logout_link
  end

  def opt_out(driver)
    toggle_footer_link_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    driver.find_element(:xpath, '//div[@class=\'cc-footer-berkeley\']').click
    opt_out_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    opt_out_button
    opt_out_yes_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    opt_out_yes
  end

end