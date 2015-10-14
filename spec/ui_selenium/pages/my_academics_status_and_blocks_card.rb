require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyAcademicsStatusAndBlocksCard < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    table(:status_table, :xpath => '//h3[text()="Status"]/following-sibling::table')
    span(:reg_status_summary, :xpath => '//th[contains(.,"Registration")]/following-sibling::td/span[@data-ng-bind="studentInfo.regStatus.summary"]')
    div(:reg_status_explanation, :xpath => '//td[@data-ng-bind-html="studentInfo.regStatus.explanation"]')
    image(:reg_status_icon_green, :xpath => '//tr[@data-ng-if="api.user.profile.features.regstatus"]//i[@class="cc-icon fa fa-check-circle cc-icon-green"]')
    image(:reg_status_icon_red, :xpath => '//tr[@data-ng-if="api.user.profile.features.regstatus"]//i[@class="cc-icon fa fa-exclamation-circle cc-icon-red"]')

    span(:res_status_summary, :xpath => '//th[contains(.,"California Residency")]/following-sibling::td/span[@data-ng-bind="studentInfo.californiaResidency.summary"]')
    image(:res_status_icon_green, :xpath => '//th[contains(.,"California Residency")]/following-sibling::td//i[@class="cc-icon fa fa-check-circle cc-icon-green"]')
    image(:res_status_icon_red, :xpath => '//th[contains(.,"California Residency")]/following-sibling::td//i[@class="cc-icon fa fa-exclamation-circle cc-icon-red"]')
    link(:res_info_link, :xpath => '//a[contains(text(),"Establishing California residency"]')

    h3(:active_blocks_heading, :xpath => '//h3[text()="Active Blocks"]')
    table(:active_blocks_table, :xpath => '//h3[text()="Active Blocks"]/following-sibling::div[@data-ng-if="regblocks.activeBlocks.length"]/table')
    cell(:active_block_message, :xpath => '//td[@data-cc-compile-directive="block.message"]')
    div(:no_active_blocks_message, :xpath => '//div[contains(text(),"You have no active blocks at this time.")]')

    button(:show_block_history_button, :xpath => '//button[contains(.,"Show Block History")]')
    button(:hide_block_history_button, :xpath => '//button[contains(.,"Hide Block History")]')
    table(:inactive_blocks_table, :xpath => '//h3[text()="Block History"]/following-sibling::div/table')
    paragraph(:no_inactive_blocks_message, :xpath => '//p[contains(text(),"No block history")]')

    def show_block_history
      WebDriverUtils.wait_for_page_and_click show_block_history_button_element
    end

    def hide_block_history
      WebDriverUtils.wait_for_page_and_click hide_block_history_button_element
    end

    def active_block_count
      active_blocks_table_element.rows - 1
    end

    def active_block_types
      types = []
      active_blocks_table_element.each do |row|
        type = row[0].text
        types.push(type)
      end
      types.drop(1)
    end

    def active_block_reasons
      reasons = []
      active_blocks_table_element.each do |row|
        reason = row[1].text
        reasons.push(reason)
      end
      reasons.drop(1)
    end

    def active_block_offices
      offices = []
      active_blocks_table_element.each do |row|
        office = row[2].text
        offices.push(office)
      end
      offices.drop(1)
    end

    def active_block_dates
      dates = []
      active_blocks_table_element.each do |row|
        date = row[3].text
        dates.push(date)
      end
      dates.drop(1)
    end

    def inactive_block_count
      inactive_blocks_table_element.rows - 1
    end

    def inactive_block_types
      types = []
      inactive_blocks_table_element.each do |row|
        type = row[0].text
        types.push(type)
      end
      types.drop(1)
    end

    def inactive_block_dates
      dates = []
      inactive_blocks_table_element.each do |row|
        date = row[1].text
        dates.push(date)
      end
      dates.drop(1)
    end

    def inactive_block_cleared_dates
      dates = []
      inactive_blocks_table_element.each do |row|
        date = row[2].text
        dates.push(date)
      end
      dates.drop(1)
    end
  end
end
