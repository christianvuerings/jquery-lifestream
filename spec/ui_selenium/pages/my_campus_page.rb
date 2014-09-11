require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyCampusPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    wait_for_expected_title('Campus - Academic Departments | CalCentral', WebDriverUtils.page_load_timeout)

    h3(:academic_heading, :xpath => '//h3[text()="Academic"]')
    h3(:administrative_heading, :xpath => '//h3[text()="Administrative"]')

    def load_page(driver)
      logger.info('Loading the My Campus page')
      driver.get(WebDriverUtils.base_url + '/campus')
    end

  end
end
