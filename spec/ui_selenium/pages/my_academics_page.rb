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
    div(:student_semesters, :xpath => '//div[@data-ng-if="api.user.profile.hasStudentHistory && semesters.length"]')
    div(:teaching_semesters, :xpath => '//div[@data-ng-if="hasTeachingClasses"]')

    def load_page
      logger.info('Loading My Academics page')
      navigate_to "#{WebDriverUtils.base_url}/academics"
    end

    def load_semester_page(semester_slug)
      logger.info("Loading semester page for #{semester_slug}")
      navigate_to "#{WebDriverUtils.base_url}/academics/semester/#{semester_slug}"
    end

    def load_class_page(class_page_url)
      logger.info("Loading class page at '#{class_page_url}'")
      navigate_to "#{WebDriverUtils.base_url}#{class_page_url}"
    end

    def has_student_semester_link(semester)
      student_semesters_element.link_element(:xpath => "//a[contains(.,'#{semester}')]").exists?
    end

    def click_student_semester_link(semester_name)
      logger.info("Clicking link for #{semester_name}")
      WebDriverUtils.wait_for_page_and_click student_semesters_element.link_element(:xpath => "//a[contains(.,'#{semester_name}')]")
    end

    def click_teaching_semester_link(semester_name)
      logger.info("Clicking link for #{semester_name}")
      WebDriverUtils.wait_for_page_and_click teaching_semesters_element.link_element(:xpath => "//a[text()='#{semester_name}']")
    end

  end
end
