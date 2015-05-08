require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'

module CalCentralPages

  class MyAcademicsClassesCard < MyAcademicsPage

    include PageObject
    include CalCentralPages

    span(:semester_heading, :xpath => '//span[@data-ng-bind="widgetSemesterName"]')

    elements(:enrolled_course_codes, :link, :xpath => '//tbody[@data-ng-repeat="course in enrolledCourses"]//a[@data-ng-bind="course.course_code"]')
    elements(:enrolled_course_titles, :td, :xpath => '//tbody[@data-ng-repeat="course in enrolledCourses"]//td[@data-ng-bind="course.title"]')
    elements(:enrolled_grade_options, :td, :xpath => '//tbody[@data-ng-repeat="course in enrolledCourses"]//td[@data-ng-bind="course.gradeOption"]')
    elements(:enrolled_units, :td, :xpath => '//tbody[@data-ng-repeat="course in enrolledCourses"]//td[@data-ng-bind="course.units | number:1"]')
    elements(:enrolled_sections, :span, :xpath => '//tbody[@data-ng-repeat="course in enrolledCourses"]//div[@data-ng-repeat="section in course.sections"]/span[@data-ng-bind="section.section_label"]')
    div(:no_enrollment_message, :xpath => '//div[contains(text(),"You are not currently enrolled in any courses")]')

    elements(:waitlist_course_codes, :link, :xpath => '//h3[text()="Wait Lists"]/following-sibling::div//a[@data-ng-bind="course.course_code"]')
    elements(:waitlist_sections, :span, :xpath => '//h3[text()="Wait Lists"]/following-sibling::div//span[@data-ng-bind="section.section_label"]')
    elements(:waitlist_course_titles, :td, :xpath => '//h3[text()="Wait Lists"]/following-sibling::div//td[@data-ng-bind="course.title"]')
    elements(:waitlist_positions, :td, :xpath => '//h3[text()="Wait Lists"]/following-sibling::div//strong[@data-ng-bind="section.waitlistPosition"]')
    elements(:waitlist_class_size, :td, :xpath => '//h3[text()="Wait Lists"]/following-sibling::div//strong[@data-ng-bind="section.enroll_limit"]')

    elements(:teaching_course_code, :link, :xpath => '//tbody[@data-ng-repeat="course in selectedTeachingSemester.classes"]//a[@data-ng-bind="listing.course_code"]')
    elements(:teaching_course_title, :td, :xpath => '//tbody[@data-ng-repeat="course in selectedTeachingSemester.classes"]//td[@data-ng-bind="course.title"]')
    elements(:teaching_course_section, :div, :xpath => '//div[@data-ng-repeat="scheduledSection in course.scheduledSections"]')

    def all_enrolled_course_codes
      codes = []
      enrolled_course_codes_elements.each { |code| codes.push(code.text) }
      codes
    end

    def all_enrolled_course_titles
      titles = []
      enrolled_course_titles_elements.each { |title| titles.push(title.text) }
      titles
    end

    def all_enrolled_grade_options
      options = []
      enrolled_grade_options_elements.each { |option| options.push(option.text) }
      options
    end

    def all_enrolled_units
      units = []
      enrolled_units_elements.each { |unit| units.push(unit.text)}
      units
    end

    def all_enrolled_sections
      sections = []
      enrolled_sections_elements.each { |section| sections.push(section.text) }
      sections
    end

    def all_waitlist_course_codes
      codes = []
      waitlist_course_codes_elements.each { |code| codes.push(code.text) }
      codes
    end

    def all_waitlist_sections
      sections = []
      waitlist_sections_elements.each { |section| sections.push(section.text) }
      sections
    end

    def all_waitlist_course_titles
      titles = []
      waitlist_course_titles_elements.each { |title| titles.push(title.text) }
      titles
    end

    def all_waitlist_positions
      positions = []
      waitlist_positions_elements.each { |position| positions.push(position.text) }
      positions
    end

    def all_waitlist_class_sizes
      sizes = []
      waitlist_class_size_elements.each { |size| sizes.push(size.text) }
      sizes
    end

    def all_teaching_course_codes
      codes = []
      teaching_course_code_elements.each { |code| codes.push(code.text) }
      codes
    end

    def all_teaching_course_titles
      titles = []
      teaching_course_title_elements.each { |title| titles.push(title.text) }
      titles
    end

    def all_teaching_course_sections
      sections = []
      teaching_course_section_elements.each { |section| sections.push(section.text) }
      sections
    end

  end
end
