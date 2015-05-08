require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsTeachingCard < MyAcademicsPage

    include PageObject
    include CalCentralPages

    elements(:semester_link, :link, :xpath => '//div[@data-ng-if="hasTeachingClasses"]//a[@data-ng-bind="semester.name"]')
    elements(:course_code, :link, :xpath => '//a[@data-ng-bind="listing.course_code"]')
    button(:show_more, :xpath => '//button[@data-ng-if="pastSemestersTeachingCount > 1"]/span[text()="Show More"]')
    button(:show_less, :xpath => '//button[@data-ng-if="pastSemestersTeachingCount > 1"]/span[text()="Show Less"]')
    paragraph(:no_classes_msg, :xpath => '//p[contains(text(),"You are officially an instructor at UC Berkeley, but no courses assigned to you are currently available through campus services.")]')

    def teaching_terms_visible?(term_names)
      terms_in_ui = []
      semester_link_elements.each { |link| terms_in_ui.push(link.text) }
      if terms_in_ui.sort == term_names.sort
        true
      else
        false
      end
    end

    def all_semester_course_codes(driver, semester_name)
      codes = []
      code_elements = driver.find_elements(:xpath, "//div[@data-ng-if='hasTeachingClasses']//a[text()='#{semester_name}']/../following-sibling::div//a[@data-ng-bind='listing.course_code']")
      code_elements.each { |element| codes.push(element.text) }
      codes
    end

    def all_semester_course_titles(driver, semester_name)
      titles = []
      title_elements = driver.find_elements(:xpath => "//div[@data-ng-if='hasTeachingClasses']//a[text()='#{semester_name}']/../following-sibling::div//div[@data-ng-bind='class.title']")
      title_elements.each { |element| titles.push(element.text) }
      titles
    end
  end
end
