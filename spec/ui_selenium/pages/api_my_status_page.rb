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

  def full_name
    @parsed['fullName']
  end

  def sid
    @parsed['sid']
  end

  def roles
    @parsed['roles']
  end

  def is_student?
    roles['student']
  end

  def is_registered?
    roles['registered']
  end

  def is_ex_student?
    roles['exStudent']
  end

  def is_faculty?
    roles['faculty']
  end

  def is_staff?
    roles['staff']
  end

  def is_guest?
    roles['guest']
  end

  def is_concurrent_enroll_student?
    roles['concurrentEnrollmentStudent']
  end

  def has_student_history?
    @parsed['hasStudentHistory']
  end

  def has_academics_tab?
    @parsed['hasAcademicsTab']
  end

  def has_finances_tab?
    @parsed['hasFinancialsTab']
  end

end
