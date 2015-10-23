require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsFinalExamsCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    h2(:final_exams_card_heading, :xpath => '//h2[contains(text(),"Final Exam Schedule")]')
    elements(:exam_dates, :span, :xpath => '//span[@data-ng-bind="exam.date.epoch * 1000 | date:\'EEE MMM d\'"]')
    elements(:exam_times, :span, :xpath => '//span[@data-ng-bind="exam.time"]')
    elements(:exam_course_codes, :div, :xpath => '//div[@class="cc-widget-exam-schedule-content"]/strong[@data-ng-bind="exam.course_code"]')
    elements(:exam_locations, :div, :xpath => '//div[@class="cc-widget-exam-schedule-content"]/strong[@data-ng-bind="exam.course_code"]/following-sibling::div')
    elements(:exam_location_links, :link, :xpath => '//div[@data-locations="exam.locations"]//a')
    elements(:exam_location_non_links, :span, :xpath => '//div[@data-locations="exam.locations"]/div/span')

    def all_exam_dates
      dates = []
      exam_dates_elements.each { |date| dates.push(date.text) }
      dates
    end

    def all_exam_times
      times = []
      exam_times_elements.each { |time| times.push(time.text) }
      times
    end

    def all_exam_courses
      courses = []
      exam_course_codes_elements.each { |course| courses.push(course.text) }
      courses
    end

    def all_exam_locations
      locations = []
      exam_location_links_elements.each do |link|
        locations.push(link.text.gsub("\n- opens in new window", ""))
      end
      exam_location_non_links_elements.each do |text|
        locations.push(text.text)
      end
      locations.sort
    end
  end
end
