require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class SettingsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    h1(:page_heading, :xpath => '//h1[contains(.,"Settings")]')

    # bConnected
    button(:disconnect_button, :xpath => '//button[@data-ng-click="api.user.removeOAuth(service)"]')
    button(:connect_button, :xpath => '//button[@data-ng-click="api.user.enableOAuth(\'Google\')"]')

    # View-as
    text_field(:view_as_input, :id => 'cc-settings-act-as-uid')
    button(:view_as_button, :xpath => '//button[@type="submit"]')
    button(:stop_viewing_as_button, :xpath => '//button[@type="button"]')
    span(:viewing_as_uid, :xpath => '//span[@data-ng-bind="api.user.profile.uid"]')

    def load_page(driver)
      driver.get(WebDriverUtils.base_url + '/settings')
      page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    end

    def disconnect_bconnected(driver)
      logger.info('Checking if user is connected to Google')
      if disconnect_button_element.visible?
        logger.info('User is connected, so disconnecting from Google')
        disconnect_button
        wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
        wait.until { driver.find_element(:xpath => '//button[@data-ng-click="api.user.enableOAuth(\'Google\')"]') }
        logger.info('Pausing so that OAuth token is revoked')
        sleep(WebDriverUtils.google_oauth_timeout)
      else
        logger.info('User not connected')
      end
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
