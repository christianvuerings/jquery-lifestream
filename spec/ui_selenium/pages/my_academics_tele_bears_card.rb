require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsTeleBearsCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    h2(:tele_bears_card_heading, :xpath => '//h2[text()="Tele-BEARS"]')
    elements(:semester_heading, :h3, :xpath => '//h3[contains(.,"Tele-BEARS for")]')
    elements(:more_info_link, :link, :xpath => '//h3[contains(text(),"Tele-BEARS for")]//a[contains(text(),"More Info")][@href="http://registrar.berkeley.edu/tbfaqs.html"]')
    link(:more_info_semester_link, :xpath => '//a[contains(text(),"More Info")][@href="http://registrar.berkeley.edu/tbfaqs.html"]')
    elements(:advisor_code_icon, :image, :xpath => '//div[@class="cc-clearfix cc-academics-advisor-message-container ng-scope"]//i')
    elements(:advisor_code_msg, :div, :xpath => '//div[@data-ng-switch="telebears.advisorCodeRequired.type"]')
    elements(:phase_start_time, :div, :xpath => '//h4[contains(.,"Tele-BEARS Phase ")]/following-sibling::ul//div[@data-ng-bind="phase.startTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')
    elements(:phase_end_time, :div, :xpath => '//h4[contains(.,"Tele-BEARS Phase ")]/following-sibling::ul//div[@data-ng-bind="phase.endTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')

    def all_telebears_semesters
      semester_headings = []
      semester_heading_elements.each { |heading| semester_headings.push(heading.text)  }
      semester_headings
    end

    def all_telebears_advisor_icons
      icons = []
      advisor_code_icon_elements.each do |icon|
        icon_type = icon.attribute('class')
        if icon_type == 'cc-left fa fa-exclamation-circle cc-icon-red'
          icon_type = true
        elsif icon_type == 'cc-left fa fa-check-circle cc-icon-green'
          icon_type = false
        else
          icon_type = nil
        end
        icons.push(icon_type)
      end
      icons
    end

    def all_telebears_advisor_msgs
      messages = []
      advisor_code_msg_elements.each { |msg| messages.push(msg.text) }
      messages
    end

    def all_phase_start_times
      start_times = []
      phase_start_time_elements.each { |time| start_times.push(time.text) }
      start_times
    end

    def all_phase_end_times
      end_times = []
      phase_end_time_elements.each { |time| end_times.push(time.text) }
      end_times
    end
  end
end
