require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class SettingsPage

    include PageObject
    include CalCentralPages

    h1(:page_heading, :xpath => '//h1[contains(.,"Settings")]')

    # View-as
    text_field(:view_as_input, :id => 'cc-settings-act-as-uid')
    button(:view_as_button, :xpath => '//button[@type="submit"]')
    button(:stop_viewing_as_button, :xpath => '//button[@type="button"]')
    span(:viewing_as_uid, :xpath => '//span[@data-ng-bind="api.user.profile.uid"]')

    def load_page(driver)
      driver.get(WebDriverUtils.base_url + '/settings')
      page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    end

    def view_as_user(driver, uid)
      view_as_input_element.when_visible(timeout=5)
      self.view_as_input = uid
      view_as_button_element.when_visible(timeout=5)
      view_as_button
      wait = Selenium::WebDriver::Wait.new(timeout => WebDriverUtils.page_load_timeout)
      wait.until { driver.find_element(:xpath, '//span[@data-ng-bind="api.user.profile.uid"][contains(.,"' + uid + '")]') }
    end

    def stop_viewing_as_user
      stop_viewing_as_button_element.when_visible(timeout=5)
      stop_viewing_as_button
    end

  end
end
