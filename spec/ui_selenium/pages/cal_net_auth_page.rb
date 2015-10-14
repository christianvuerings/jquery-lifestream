require 'rubygems'
require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'
require_relative '../util/user_utils'

  class CalNetAuthPage

    include PageObject

    h2(:page_heading, :xpath => '//h2[contains(.,"CalNet Authentication Service")]')
    h3(:login_message, :xpath => '//h3[@class="login-message"]')
    h3(:logout_conf_heading, :xpath => '//h3[contains(.,"Logout Successful")]')
    text_field(:username, :id => 'username')
    text_field(:password, :id => 'password')
    button(:submit, :value => 'Sign In')
    link(:logout_link, :link => 'Log Out')

    def load_page
      navigate_to WebDriverUtils.cal_net_url
      page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    end

    def login(username, password)
      WebDriverUtils.wait_for_element_and_type(username_element, username)
      WebDriverUtils.wait_for_element_and_type(password_element, password)
      submit
    end

    def logout
      navigate_to "#{WebDriverUtils.cal_net_url}/cas/logout"
      logout_conf_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
    end

  end
