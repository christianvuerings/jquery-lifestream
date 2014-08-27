require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  module MyDashboardPage

    include PageObject
    include CalCentralPages

    wait_for_expected_title('Dashboard | CalCentral', WebDriverUtils.page_load_timeout)

    h3(:connect_bconnected_heading, :xpath => '//h3[contains(.,"Connect to bConnected")]')
    button(:connect_bconnected_button, :xpath => '//button[contains(.,"Connect")]')
    h2(:recent_activity_heading, :xpath => '//h2[contains(.,"Recent Activity")]')

    def self.load_page(driver)
      Rails.logger.info('Loading My Dashboard page')
      driver.get(WebDriverUtils.base_url + '/dashboard')
    end
  end
end
