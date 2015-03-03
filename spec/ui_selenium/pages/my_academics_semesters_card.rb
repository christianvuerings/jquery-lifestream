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
    link(:order_transcripts_link, :xpath => '//h2[text()="Semesters"]/following-sibling::a[contains(.,"Order Transcripts")]')
    button(:show_more, :xpath => '//button[@data-ng-if="pastSemestersCount > 1"]/span[text()="Show More"]')
    button(:show_less, :xpath => '//button[@data-ng-if="pastSemestersCount > 1"]/span[text()="Show Less"]')

    def student_terms_visible?(term_names)
      links = []
      semester_links_elements.each { |link| links.push(link.text) }
      if links.sort == term_names.sort
        true
      else
        false
      end
    end

    def prim_sec_course_codes(driver, semester_name)
      codes = []
      code_elements = driver.find_elements(:xpath => "//h3[contains(.,'#{semester_name}')]/following-sibling::table//a[@data-ng-bind='class.course_code']")
      code_elements.each { |element| codes.push(element.text) }
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
  end
end
