require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

class CalCentralPages::MyAcademicsPage

  include PageObject
  include CalCentralPages

  wait_for_expected_title('My Academics | CalCentral')

  h1(:page_heading, :xpath => '//h1')
  link(:first_student_semester_link, :xpath => '//div[@class="cc-academics-semesters"]//a')

  def load_page(driver)
    driver.get(WebDriverUtils.base_url + '/academics')
  end

  def click_first_student_semester
    first_student_semester_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    first_student_semester_link
  end

end
