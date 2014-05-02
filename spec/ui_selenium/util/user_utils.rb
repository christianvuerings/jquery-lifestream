require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/settings_page'
require_relative '../pages/cal_net_auth_page'
require_relative '../util/web_driver_utils'

class UserUtils

  include PageObject

  @config = YAML.load_file((ENV['HOME'] + '/.calcentral_config/authentication.yml'))

  def self.admin_username
    @config['calnet_paul']['username']
  end

  def self.admin_password
    @config['calnet_paul']['password']
  end

  def self.oski_username
    @config['calnet_oski']['username']
  end

  def self.oski_password
    @config['calnet_oski']['password']
  end

  def self.test_password
    @config['calnet_test']['password']
  end

  def self.student_username
    @config['calnet_student']['username']
  end

  def self.view_as(driver, uid, settings_page, cal_net_page)
    settings_page.view_as_input_element.when_visible(timeout=5)
    settings_page.view_as_input = uid
    settings_page.view_as_button_element.when_visible(timeout=5)
    settings_page.view_as_button
    sleep(1)
    if driver.title == 'CalNet Central Authentication Service - Single Sign-on'
      cal_net_page.login_admin
    end
    wait = Selenium::WebDriver::Wait.new(timeout => WebDriverUtils.page_load_timeout)
    wait.until { driver.find_element(:xpath, '//span[@data-ng-bind="api.user.profile.uid"][contains(.,"' + uid + '")]') }
  end

end