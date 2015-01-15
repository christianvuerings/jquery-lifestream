require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsAdvisingCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    h2(:advising_card_heading, :xpath => '//h2[text()="L&S Advising"]')
    div(:advising_card_spinner, :xpath => '//h2[text()="L&S Advising"]/../following-sibling::div[@class="cc-spinner"]')
    paragraph(:make_appt_msg, :xpath => '//p[@data-ng-if="urlToMakeAppointment"]')
    link(:make_appt_link, :xpath => '//a[@href="https://bhive.berkeley.edu/appointments/new"][contains(.,"new appointment")]')
    span(:college_adviser_link, :xpath => '//h3[contains(.,"College Advisor")]/following-sibling::a/span')

    h3(:future_appts_heading, :xpath => '//h3[text()="Current Appointments"]')
    elements(:future_appts, :list_item, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]')
    elements(:future_appt_dates, :div, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]//strong[@data-ng-bind="appointment.dateTime | dateInYearFilter:\'MM/dd\':\'MM/dd/yy\'"]')
    elements(:future_appt_times, :div, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]//span[@data-ng-bind="appointment.dateTime | date:\'h:mm a\'"]')
    elements(:future_appt_advisors, :div, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]//strong[@data-ng-bind="appointment.staff.name"]')
    elements(:future_appt_methods, :span, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]//span[@data-ng-bind="appointment.method"]')
    elements(:future_appt_locations, :span, :xpath => '//li[@data-ng-repeat="appointment in futureAppointments"]//span[@data-ng-bind="appointment.location"]')
    elements(:future_appt_toggles, :div, :xpath => '//div[@data-ng-click="api.widget.toggleShow($event, futureAppointments, appointment, \'Current Appointment\')"]')
    link(:update_appt_link, :xpath => '//a[contains(@href, "https://bhive.berkeley.edu/appointments/")][contains(.,"Update Appointment")]')

    button(:show_prev_appts_button, :xpath => '//button[contains(.,"Show Previous Appointments")]')
    button(:hide_prev_appts_button, :xpath => '//button[contains(.,"Hide Previous Appointments")]')
    h3(:prev_appts_heading, :xpath => '//h3[text()="Previous Appointments"]')
    table(:prev_appts_table, :xpath => '//h3[text()="Previous Appointments"]/following-sibling::div/table')

    def all_future_appt_dates
      dates = []
      future_appt_dates_elements.each { |date| dates.push(date.text) }
      dates
    end

    def all_future_appt_times
      times = []
      future_appt_times_elements.each { |time| times.push(time.text) }
      times
    end

    def all_future_appt_advisers
      advisors = []
      future_appt_advisors_elements.each { |advisor| advisors.push(advisor.text) }
      advisors
    end

    def all_future_appt_methods
      methods = []
      future_appt_methods_elements.each { |method| methods.push(method.text) }
      methods
    end

    def all_future_appt_locations
      locations = []
      future_appt_locations_elements.each { |location| locations.push(location.text) }
      locations
    end

    def all_prev_appt_dates
      dates = []
      prev_appts_table_element.each do |row|
        date = row[0].text
        dates.push(date)
      end
      dates.drop(1)
    end

    def all_prev_appt_advisers
      advisers = []
      prev_appts_table_element.each do |row|
        adviser = row[1].text
        advisers.push(adviser)
      end
      advisers.drop(1)
    end
  end
end