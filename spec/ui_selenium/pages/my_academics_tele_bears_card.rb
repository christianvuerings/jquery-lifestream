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

    link(:more_info_link, :xpath => '//h3[contains(.,"Tele-BEARS for")]//a[contains(.,"More Info")]')
    div(:code_required_icon, :xpath => '//div[@class="cc-clearfix cc-academics-adviser-message-container ng-scope"]//i[@class="cc-left fa fa-exclamation-circle cc-icon-red"]')
    div(:code_not_required_icon, :xpath => '//div[@class="cc-clearfix cc-academics-adviser-message-container ng-scope"]//i[@class="cc-left fa fa-check-circle cc-icon-green"]')
    div(:adviser_code_msg, :xpath => '//div[@data-ng-bind="telebears.adviserCodeRequired.message"]')
    div(:phase_one_start_time, :xpath => '//h4[text()="Tele-BEARS Phase I"]/following-sibling::ul//div[@data-ng-bind="phase.startTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')
    div(:phase_one_end_time, :xpath => '//h4[text()="Tele-BEARS Phase I"]/following-sibling::ul//div[@data-ng-bind="phase.endTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')
    div(:phase_two_start_time, :xpath => '//h4[text()="Tele-BEARS Phase II"]/following-sibling::ul//div[@data-ng-bind="phase.startTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')
    div(:phase_two_end_time, :xpath => '//h4[text()="Tele-BEARS Phase II"]/following-sibling::ul//div[@data-ng-bind="phase.endTime.epoch * 1000 | dateUnlessNoonFilter:\'EEE MMM d | h:mm a\'"]')

  end
end