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
    paragraph(:make_appt_msg, :xpath => '//p[@data-ng-if="urlToMakeAppointment"]')
    link(:make_appt_link, :text => 'new appointment - opens in new window')
    link(:college_advisor_link, :xpath => '//h3[text()="College Advisor"]/a')
    button(:show_prev_appts_button, :xpath => '//button[@data-ng-if="pastAppointments.length"]')
    table(:prev_appts_table, :xpath => '//h3[text()="Previous Appointments"]//table')


  end
end