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
    h2(:no_data_heading, :xpath => '//h2[contains(text(),"Data not available")]')

    def load_page(driver)
      logger.info('Loading My Academics page')
      driver.get("#{WebDriverUtils.base_url}/academics")
    end

    def load_semester_page(driver, semester_slug)
      logger.info("Loading semester page for #{semester_slug}")
      driver.get("#{WebDriverUtils.base_url}/academics/semester/#{semester_slug}")
    end

    def load_class_page(driver, class_page_url)
      logger.info("Loading class page at '#{class_page_url}'")
      driver.get("#{WebDriverUtils.base_url}#{class_page_url}")
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

    def click_student_semester_link(driver, semester_name)
      logger.info("Clicking link for #{semester_name}")
      wait_until(timeout=WebDriverUtils.page_load_timeout) { driver.find_element(:xpath => "//div[@data-ng-if='api.user.profile.hasStudentHistory && semesters.length']//a[text()='#{semester_name}']") }
      driver.find_element(:link_text => semester_name).click
    end

    def click_teaching_semester_link(driver, semester_name)
      logger.info("Clicking link for #{semester_name}")
      wait_until(timeout=WebDriverUtils.page_load_timeout) { driver.find_element(:xpath => "//div[@data-ng-if='hasTeachingClasses']//a[text()='#{semester_name}']") }
      driver.find_element(:xpath => "//div[@data-ng-if='hasTeachingClasses']//a[text()='#{semester_name}']").click
    end

    def click_class_link_by_text(driver, link_text)
      wait_until(timeout=WebDriverUtils.page_load_timeout) { driver.find_element(:link_text => link_text) }
      driver.find_element(:link_text => link_text).click
    end

    def click_class_link_by_url(driver, url)
      wait_until(timeout=WebDriverUtils.page_load_timeout) { driver.find_element(:xpath => "//a[@href='#{url}']") }
      driver.find_element(:xpath => "//a[@href='#{url}']").click
    end
  end
end
