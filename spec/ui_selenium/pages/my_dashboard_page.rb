require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

class CalCentralPages::MyDashboardPage

  include PageObject
  include CalCentralPages

  h2(:connect_bconnected_heading, :xpath => '//h2[contains(.,"Connect CalCentral to bConnected")]')
  wait_for_expected_title('Dashboard | CalCentral', WebDriverUtils.page_load_timeout)

  def load_page(driver)
    driver.get(WebDriverUtils.base_url + '/dashboard')
  end

end