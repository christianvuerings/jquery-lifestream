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

    # View As
    text_area(:view_as_input, :id => 'cc-settings-act-as-uid')
    button(:view_as_submit_button, :xpath => '//button[text()="Submit"]')
    div(:saved_users, :xpath => '//div[@class="row cc-settings-recent-uids ng-scope"][1]')
    button(:clear_saved_users_button, :xpath => '//span[text()="Saved Users"]/following-sibling::button[text()="clear all"]')
    elements(:saved_user_view_as_button, :div, :xpath => '//div[@class="row cc-settings-recent-uids ng-scope"][1]//button[@data-ng-click="admin.updateIDField(user.ldap_uid)"]')
    elements(:saved_user_delete_button, :button, :xpath => '//button[text()="delete"]')
    div(:recent_users, :xpath => '//div[@class="row cc-settings-recent-uids ng-scope"][2]')
    button(:clear_recent_users_button, :xpath => '//span[text()="Recent Users"]/following-sibling::button[text()="clear all"]')
    elements(:recent_user_view_as_button, :div, :xpath => '//div[@class="row cc-settings-recent-uids ng-scope"][2]//button[@data-ng-click="admin.updateIDField(user.ldap_uid)"]')
    elements(:recent_user_save_button, :button, :xpath => '//button[text()="save"]')

    # UID/SID Lookup
    text_area(:lookup_input, :id => 'cc-settings-id')
    button(:lookup_button, :xpath => '//button[text()="Look Up"]')
    table(:lookup_results_table, :xpath => '//form[@data-ng-submit="admin.lookupUser()"]//table')

    def load_page(driver)
      logger.info('Loading settings page')
      driver.get("#{WebDriverUtils.base_url}/settings")
    end

    def disconnect_bconnected
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

    # VIEW-AS

    def view_as_user(id)
      view_as_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      self.view_as_input = id
      view_as_submit_button
    end

    def clear_all_saved_users
      saved_users_element.when_present(timeout=WebDriverUtils.page_load_timeout)
      if clear_saved_users_button?
        clear_saved_users_button
      end
    end

    def view_as_first_saved_user
      wait_until(timeout=WebDriverUtils.page_load_timeout) { saved_user_view_as_button_elements.any? }
      saved_user_view_as_button_elements[0].click
    end

    def clear_all_recent_users
      recent_users_element.when_present(timeout=WebDriverUtils.page_load_timeout)
      if clear_recent_users_button?
        clear_recent_users_button
      end
    end

    def view_as_first_recent_user
      wait_until(timeout=WebDriverUtils.page_load_timeout) { recent_user_view_as_button_elements.any? }
      recent_user_view_as_button_elements[0].click
    end

    def save_first_recent_user
      wait_until(timeout=WebDriverUtils.page_load_timeout) { recent_user_save_button_elements.any? }
      recent_user_save_button_elements[0].click
    end

    # LOOK UP USER

    def look_up_user(id)
      lookup_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      self.lookup_input = id
      lookup_button
    end
  end
end
