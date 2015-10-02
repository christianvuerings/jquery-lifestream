require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/cal_central_pages'
require_relative '../pages/settings_page'
require_relative '../pages/cal_net_auth_page'
require_relative '../util/web_driver_utils'

class UserUtils

  include PageObject
  include CalCentralPages
  include ClassLogger

  def self.basic_auth_pass
    Settings.developer_auth.password
  end

  def self.oski_username
    Settings.ui_selenium.oski_username
  end

  def self.oski_password
    Settings.ui_selenium.oski_password
  end

  def self.oski_gmail_username
    Settings.ui_selenium.oski_gmail_username
  end

  def self.oski_gmail_password
    Settings.ui_selenium.oski_gmail_password
  end

  def self.test_password
    Settings.ui_selenium.test_user_password
  end

  def self.qa_username
    Settings.ui_selenium.ets_qa_ldap_username
  end

  def self.qa_password
    Settings.ui_selenium.ets_qa_ldap_password
  end

  def self.qa_gmail_username
    Settings.ui_selenium.ets_qa_gmail_username
  end

  def self.qa_gmail_password
    Settings.ui_selenium.ets_qa_gmail_password
  end

  def self.admin_uid
    Settings.ui_selenium.admin_uid
  end

  def self.initialize_output_csv(spec)
    output_dir = Rails.root.join('tmp', 'ui_selenium_ouput')
    output_file = spec.inspect.sub('RSpec::ExampleGroups::', '') + '.csv'
    logger.info("Initializing test output CSV named #{output_file}")
    unless File.exists?(output_dir)
      FileUtils.mkdir_p(output_dir)
    end
    Rails.root.join(output_dir, output_file)
  end

  def self.load_test_users
    logger.info('Loading test UIDs')
    JSON.parse(File.read(WebDriverUtils.live_users))['users']
  end

  def self.clear_cache(driver, splash_page, my_dashboard_page)
    splash_page.load_page driver
    splash_page.basic_auth(driver, UserUtils.admin_uid)
    driver.get "#{WebDriverUtils.base_url}/api/cache/clear"
    my_dashboard_page.load_page driver
    my_dashboard_page.click_logout_link
  end

end
