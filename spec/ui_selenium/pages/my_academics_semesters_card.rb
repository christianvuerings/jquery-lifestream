require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  class MyAcademicsSemestersCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    elements(:semester_links, :link, :xpath => '//h2[text()="Semesters"]/../following-sibling::div//a[@data-ng-bind="semester.name"]')
    elements(:no_enrollment_semester_h3, :h3, :xpath => '//h2[text()="Semesters"]/../following-sibling::div//h3[@data-ng-if="!semester.hasEnrollmentData"]')
    link(:order_transcripts_link, :xpath => '//h2[text()="Semesters"]/following-sibling::a[contains(.,"Order Transcripts")]')
    button(:show_more, :xpath => '//button[@data-ng-if="pastSemestersCount > 1"]/span[text()="Show More"]')
    button(:show_less, :xpath => '//button[@data-ng-if="pastSemestersCount > 1"]/span[text()="Show Less"]')

    elements(:addl_credit_title, :td, :xpath => '//td[@data-ng-bind="additionalCredit.title"]')
    elements(:addl_credit_units, :td, :xpath => '//td[@data-ng-bind="additionalCredit.units | number:1"]')

    def student_terms_visible?(term_names)
      terms_in_ui = []
      semester_links_elements.each { |link| terms_in_ui.push(link.text) }
      no_enrollment_semester_h3_elements.each { |heading| terms_in_ui.push(heading.text) }
      if terms_in_ui.sort == term_names.sort
        true
      else
        false
      end
    end

    def prim_sec_course_codes(driver, semester_name)
      codes = []
      course_code_link_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//a")
      course_code_link_elements.each { |element| codes.push(element.text) }
      course_code_no_link_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//td[@data-ng-if='!class.url']")
      course_code_no_link_elements.each { |element| codes.push(element.text) }
      codes
    end

    def course_titles(driver, semester_name)
      titles = []
      title_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//td[2]")
      title_elements.each { |element| titles.push(element.text) }
      titles
    end

    def units(driver, semester_name)
      units = []
      units_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//td[3]")
      units_elements.each { |element| units.push(element.text) }
      units
    end

    def grades(driver, semester_name)
      grades = []
      grades_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//td[4]")
      grades_elements.each { |element| grades.push(element.text) }
      grades
    end

    def addl_credit_titles
      titles = []
      addl_credit_title_elements.each { |title| titles.push(title.text) }
      titles
    end

    def addl_credit_units
      units = []
      addl_credit_units_elements.each { |unit| units.push(unit.text) }
      units
    end
  end
end
