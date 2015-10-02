require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  class MyDashboardMyClassesCard < MyDashboardPage

    span(:term_name, :xpath => '//span[@data-ng-bind="current_term"]')
    div(:spinner, :xpath => '//h2[contains(text(),"My Classes")]/../following-sibling::div[@class="cc-spinner"]')
    div(:no_classes_msg, :xpath => '//div[contains(text(),"There are currently no classes available.")]')
    div(:not_enrolled_msg, :xpath => '//div[contains(.,"You are not enrolled in any UC Berkeley classes this semester.")]')
    paragraph(:not_teaching_msg, :xpath => '//p[text()="You have no classes assigned to you this semester."]')
    paragraph(:not_enrolled_not_teaching_msg, :xpath => '//p[text()="You are not enrolled in any UC Berkeley classes and you have no classes assigned to you this semester."]')
    paragraph(:eap_student_msg, :xpath => '//p[text()="You are enrolled in the Education Abroad Program this semester."]')
    link(:registrar_link, :text => "Office of the Registrar\n- opens in new window")
    link(:cal_student_central_link, :text => "Cal Student Central\n- opens in new window")

    h3(:enrollments_heading, :xpath => '//h2[contains(text(),"My Classes")]/../following-sibling::div//h3[text()="Enrollments"]')
    div(:enrolled_classes_div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]')
    elements(:enrolled_class_link, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]//div[@data-ng-repeat="listing in class.listings"]/a')
    elements(:wait_list_position, :span, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]//span[@data-ng-show="class.waitlistPosition"]')
    elements(:enrolled_class_name, :div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]//div[@data-ng-bind="class.name"]')
    elements(:enrolled_course_site_link, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]//a[@data-ng-bind="subclass.name"]')
    elements(:enrolled_course_site_desc, :div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-student\'"]//div[@data-ng-bind="subclass.shortDescription"]')

    h3(:teaching_heading, :xpath => '//h3[text()="Teaching"]')
    div(:teaching_classes_div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-instructor\'"]')
    elements(:teaching_class_link, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-instructor\'"]//div[@data-ng-repeat="listing in class.listings"]/a')
    elements(:teaching_class_name, :div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-instructor\'"]//div[@data-ng-bind="class.name"]')
    elements(:teaching_course_site_link, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-instructor\'"]//a[@data-ng-bind="subclass.name"]')
    elements(:teaching_course_site_desc, :div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-instructor\'"]//div[@data-ng-bind="subclass.shortDescription"]')

    h3(:other_sites_heading, :xpath => '//h3[text()="Other Site Memberships"]')
    div(:other_sites_div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-other\'"]')
    elements(:other_course_site_link, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-other\'"]//a[@data-ng-switch-when="other"]')
    elements(:other_course_site_name, :link, :xpath => '//div[@data-ng-class="\'cc-widget-classes-other\'"]//div[@data-ng-bind="class.name"]')
    elements(:other_course_site_desc, :div, :xpath => '//div[@data-ng-class="\'cc-widget-classes-other\'"]//div[@data-ng-bind="class.shortDescription"]')

    def enrolled_course_codes
      codes = []
      enrolled_class_link_elements.each { |link| codes << link.text }
      codes
    end

    def enrolled_course_titles
      titles = []
      enrolled_class_name_elements.each { |name| titles << name.text }
      titles
    end

    def wait_list_positions
      positions = []
      wait_list_position_elements.each do |position|
        number = position.text.gsub('- #', '').gsub(' on the wait list', '')
        positions << number unless number == ''
      end
      positions
    end

    def enrolled_course_site_names
      names = []
      enrolled_course_site_link_elements.each { |link| names << link.text.gsub("\n- opens in new window", '') }
      names
    end

    def enrolled_course_site_descrips
      descriptions = []
      enrolled_course_site_desc_elements.each { |descrip| descriptions << descrip.text unless descrip.text == '' }
      descriptions
    end

    def teaching_course_codes
      codes = []
      teaching_class_link_elements.each { |link| codes << link.text }
      codes
    end

    def teaching_course_titles
      titles = []
      teaching_class_name_elements.each { |name| titles << name.text }
      titles
    end

    def teaching_course_site_names
      names = []
      teaching_course_site_link_elements.each { |link| names << link.text.gsub("\n- opens in new window", '') }
      names
    end

    def teaching_course_site_descrips
      descriptions = []
      teaching_course_site_desc_elements.each { |descrip| descriptions << descrip.text }
      descriptions
    end

    def other_course_site_names
      names = []
      other_course_site_name_elements.each { |name| names << name.text.gsub("\n- opens in new window", '') }
      names
    end

    def other_course_site_descrips
      descriptions = []
      other_course_site_desc_elements.each { |descrip| descriptions << descrip.text }
      descriptions
    end

  end
end
