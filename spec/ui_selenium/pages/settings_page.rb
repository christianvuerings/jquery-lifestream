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

    # Student Lookup
    button(:search_tab, :xpath => '//button[@data-ng-click="admin.switchSelectedOption(selectOption)"][text()="Search"]')
    button(:saved_tab, :xpath => '//button[@data-ng-click="admin.switchSelectedOption(selectOption)"][text()="Saved"]')
    button(:recent_tab, :xpath => '//button[@data-ng-click="admin.switchSelectedOption(selectOption)"][text()="Recent"]')
    text_area(:uid_sid_input, :id => 'cc-widget-student-lookup-search')
    button(:search_button, :xpath => '//button[@type="submit"]')
    table(:search_results_table, :xpath => '//div[@data-ng-repeat="tab in admin.tabs"][1]//table')
    table(:saved_users_table, :xpath => '//div[@data-ng-repeat="tab in admin.tabs"][2]//table')
    table(:recent_users_table, :xpath => '//div[@data-ng-repeat="tab in admin.tabs"][3]//table')
    elements(:uid_result, :td, :xpath => '//td[@data-ng-bind="user.ldap_uid || \'none\'"]')
    button(:uid_link, :xpath => '//button[@data-ng-click="admin.changeIDType(\'UID\')"]')
    elements(:sid_result, :td, :xpath => '//td[@data-ng-bind="user.student_id || \'none\'"]')
    button(:sid_link, :xpath => '//button[@data-ng-click="admin.changeIDType(\'SID\')"]')
    button(:view_as_link, :xpath => '//button[@data-ng-click="admin.actAsUser(user)"]')
    button(:save_user_toggle, :xpath => '//button[@data-ng-click="admin.toggleSaveState(user)"]')
    elements(:user_saved, :image, :xpath => '//i[@class="fa fa-star-o"]')

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

    # VIEW-AS

    def search_for_user(id)
      search_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      search_tab
      uid_sid_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      self.uid_sid_input = id
      search_button
    end

    def view_as_user(id)
      search_for_user(id)
      search_results_table_element.when_present(timeout=WebDriverUtils.page_event_timeout)
      wait_until(timeout=WebDriverUtils.page_event_timeout) { search_results_table_element[1][0].text == id }
      view_as_link_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      view_as_link
    end

    def save_first_user_in_list
      save_user_toggle_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      save_user_toggle
      user_saved_elements[0].when_present(timeout=WebDriverUtils.page_event_timeout)
    end

    def click_saved_users_tab
      saved_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      saved_tab
    end

    def all_saved_uids
      uids = []
      saved_users_table_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      saved_users_table_element.each { |row| uids << row[0].text }
      uids.drop(1)
    end

    def all_saved_names
      names = []
      saved_users_table_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      saved_users_table_element.each { |row| names << row[1].text }
      names.drop(1)
    end

    def un_save_all_saved_users
      click_saved_users_tab
      while saved_users_table?
        row_one = save_user_toggle_element
        row_one.click
        row_one.when_not_present(timeout=WebDriverUtils.page_event_timeout)
      end
    end

    def show_uid
      if uid_link_element.visible?
        uid_link
      end
    end

    def show_sid
      if sid_link_element.visible?
        sid_link
      end
    end
  end
end
