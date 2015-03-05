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
    div(:connected_as, :xpath => '//div[@data-ng-if="api.user.profile.googleEmail && api.user.profile.hasGoogleAccessToken"]')
    checkbox(:calendar_opt_in, :id => 'cc-settings-service-calendar-optin')
    button(:disconnect_button, :xpath => '//button[contains(.,"Disconnect")]')
    button(:disconnect_yes_button, :xpath => '//button[@data-ng-click="api.user.removeOAuth(service)"]')
    button(:disconnect_no_button, :xpath => '//button[@data-ng-click="showValidation = false"]')
    button(:connect_button, :xpath => '//button[@data-ng-click="api.user.enableOAuth(service)"]')

    # View-as
    text_area(:view_as_input, :id => 'cc-settings-act-as-uid')
    button(:view_as_button, :xpath => '//button[@type="submit"]')

    # UID/SID Lookup
    text_area(:uid_sid_input, :id => 'cc-settings-id')
    button(:lookup_button, :xpath => '//button[text()="Look Up"]')
    td(:uid_result, :xpath => '//td[@data-ng-bind="user.ldap_uid"]')
    td(:sid_result, :xpath => '//td[@data-ng-bind="user.student_id || \'This user has no SID\'"]')

    def load_page(driver)
      logger.info('Loading settings page')
      driver.get(WebDriverUtils.base_url + '/settings')
    end

    def disconnect_bconnected(driver)
      logger.info('Checking if user is connected to Google')
      if disconnect_button_element.visible?
        logger.info('User is connected, so disconnecting from Google')
        disconnect_button
        disconnect_yes_button_element.when_visible(timeout = WebDriverUtils.page_event_timeout)
        disconnect_yes_button
        disconnect_yes_button_element.when_not_present(timeout=WebDriverUtils.page_event_timeout)
        connect_button_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        logger.info('Pausing so that OAuth token is revoked')
        sleep(WebDriverUtils.google_oauth_timeout)
      else
        logger.info('User not connected')
      end
    end

    def view_as_user(id)
      view_as_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      self.view_as_input = id
      view_as_button
    end

    def convert_id(id)
      uid_sid_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      self.uid_sid_input = id
      lookup_button
    end

  end
end
