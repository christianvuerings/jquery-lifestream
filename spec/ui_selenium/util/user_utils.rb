require 'selenium-webdriver'
require 'page-object'
require_relative '../pages/cal_central_pages'
require_relative '../pages/settings_page'
require_relative '../pages/cal_net_auth_page'
require_relative '../util/web_driver_utils'

class UserUtils

  include PageObject
  include CalCentralPages

  def self.basic_auth_pass
    Settings.developer_auth.password
  end

  def self.oski_username
    Settings.ui_selenium.oski_username
  end

  def self.oski_password
    Settings.ui_selenium.oski_password
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

end
