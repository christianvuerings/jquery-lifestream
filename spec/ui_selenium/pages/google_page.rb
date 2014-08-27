require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class GooglePage

  include PageObject

  text_field(:username_input, :id => 'Email')
  text_field(:password_input, :id => 'Passwd')
  button(:sign_in_button, :id => 'signIn')
  button(:approve_access_button, :id => 'submit_approve_access')

  def connect_gmail_account(driver, gmail_user, gmail_pass)
    Rails.logger.info('Connecting mail account')
    driver.get(WebDriverUtils.base_url + WebDriverUtils.google_auth_url)
    username_input_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    self.username_input = gmail_user
    self.password_input = gmail_pass
    sign_in_button
  end

end
