require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    wait_for_expected_title('My Academics | CalCentral')

    h1(:page_heading, :xpath => '//h1[contains(.,"My Academics")]')
    link(:first_student_semester_link, :xpath => '//div[@class="cc-academics-semesters"]//a')

    def load_page(driver)
      logger.info('Loading My Academics page')
      driver.get(WebDriverUtils.base_url + '/academics')
    end

    def has_student_semester_link(driver, semester)
      begin
        driver.find_element(:xpath, "//div[@data-ng-if='api.user.profile.hasStudentHistory && semesters.length']//a[contains(.,'#{semester}')]")
        logger.info("User has link for #{semester}")
        true
      rescue
        logger.info("User has no link for #{semester}")
        false
      end
    end

    def click_first_student_semester
      logger.info('Clicking the first student semester link')
      first_student_semester_link_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      first_student_semester_link
    end

    def load_semester_page(driver, semester)
      logger.info("Loading semester page for #{semester}")
      driver.get(WebDriverUtils.base_url + '/academics/semester/' + semester)
    end

    def click_semester_link(driver, semester)
      logger.info("Clicking link for #{semester}")
      wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
      wait.until { driver.find_element(:link_text => semester) }
      driver.find_element(:link_text => semester).click
    end

    def click_class_link(driver, course_code)
      wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
      wait.until { driver.find_element(:link_text => course_code) }
      driver.find_element(:link_text => course_code).click
    end
  end
end
