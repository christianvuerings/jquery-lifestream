require 'rubygems'
require 'selenium-webdriver'
require 'page-object'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'
require_relative '../util/user_utils'

module CalCentralPages

  class MyDashboardRecentActivityCard < MyDashboardPage

    include PageObject

    h2(:activity_heading, :xpath => '//h2[text()="Recent Activity"]')
    div(:spinner, :xpath => '//div[@data-ng-include="widgets/activity_list.html"]/div[@class="cc-spinner"]')
    select_list(:activities_select, :xpath => '//div[@class="cc-widget cc-widget-activities ng-scope"]//select')
    elements(:activity_item, :list_item, :xpath => '//ul[@class="cc-widget-activities-list"]/li')
    elements(:activity_item_toggle, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li/div')
    elements(:activity_item_summary, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li//strong')
    elements(:activity_item_source, :span, :xpath => '//ul[@class="cc-widget-activities-list"]/li//span[@data-ng-bind="activity.source"]')
    elements(:activity_item_date, :span, :xpath => '//ul[@class="cc-widget-activities-list"]/li//span[@data-ng-if="activity.date"]')
    elements(:activity_item_desc, :paragraph, :class => 'cc-widget-activities-summary')
    elements(:activity_more_info_link, :link, :xpath => '//ul[@class="cc-widget-activities-list"]/li//a')

    def wait_for_recent_activity
      activity_heading_element.when_visible timeout=WebDriverUtils.page_load_timeout
      sleep WebDriverUtils.page_event_timeout
      spinner_element.when_not_present timeout=WebDriverUtils.academics_timeout if spinner?
    end

    def wait_for_course_activity(driver, course_site_name)
      tries ||= 5
      logger.info("Waiting for #{course_site_name} to appear on recent activity select")
      WebDriverUtils.wait_for_element_and_select(activities_select_element, course_site_name)
    rescue
      load_page driver
      retry unless (tries -= 1).zero?
    end

    def expand_activity_detail(index)
      activity_item_toggle_elements[index].click unless activity_more_info_link_elements[index].visible?
    end

    def sub_activity_toggle_elements(driver, activity_list_node)
      driver.find_elements(:xpath, "//ul[@class='cc-widget-activities-list']/li[#{activity_list_node.to_s}]//ul/li/div")
    end

    def sub_activity_text(driver, activity_list_node, elements)
      elements_text = []
      toggles = sub_activity_toggle_elements(driver, activity_list_node)
      toggles.each do |toggle|
        unless toggle.displayed?
          activity_item_toggle_elements[activity_list_node - 1].click
          wait_until(timeout=WebDriverUtils.page_event_timeout) { toggle.displayed? }
        end
        toggle.click
        element = elements[toggles.index(toggle)]
        wait_until(timeout=WebDriverUtils.page_event_timeout) { element.displayed? }
        elements_text << element.text
      end
      elements_text
    end

    def sub_activity_summaries(driver, activity_list_node)
      elements = driver.find_elements(:xpath, "//ul[@class='cc-widget-activities-list']/li[#{activity_list_node.to_s}]//ul/li//div[contains(@class,'cc-widget-activities-sub-activity ng-binding')]")
      sub_activity_text(driver, activity_list_node, elements)
    end

    def sub_activity_descriptions(driver, activity_list_node)
      elements = driver.find_elements(:xpath, "//ul[@class='cc-widget-activities-list']/li[#{activity_list_node.to_s}]//ul/li//p")
      sub_activity_text(driver, activity_list_node, elements)
    end
  end
end
