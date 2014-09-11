require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_finances_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  module MyFinancesPages
    class MyFinancesDetailsPage

      include PageObject
      include CalCentralPages
      include MyFinancesPages
      include ClassLogger

      wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
      h1(:page_heading, :xpath => '//h1[contains(.,"Details"]')

      def load_page(driver)
        logger.info('Loading My Finances details page')
        driver.get(WebDriverUtils.base_url + '/finances/details')
      end

    end
  end
end
