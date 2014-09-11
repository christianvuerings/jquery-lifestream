require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative '../util/web_driver_utils'

class ApiMyStatusPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/status')
    driver.get(WebDriverUtils.base_url + '/api/my/status')
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def is_student?
    @parsed['roles']['student']
  end

  def is_ex_student?
    @parsed['roles']['exStudent']
  end

  def is_faculty?
    @parsed['roles']['faculty']
  end

  def is_staff?
    @parsed['roles']['staff']
  end

  def is_guest?
    @parsed['roles']['guest']
  end

  def has_academics_tab?
    @parsed['hasAcademicsTab']
  end

  def has_finances_tab?
    @parsed['hasFinancialsTab']
  end

end
