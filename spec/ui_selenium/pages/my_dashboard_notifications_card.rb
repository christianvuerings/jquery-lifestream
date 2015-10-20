require 'rubygems'
require 'selenium-webdriver'
require 'page-object'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'
require_relative '../util/user_utils'

module CalCentralPages

  class MyDashboardNotificationsCard < MyDashboardPage

    include PageObject

    h2(:notifications_heading, :xpath => '//h2[text()="Notifications"]')
    div(:spinner, :xpath => '//div[@data-ng-include="widgets/activity_list.html"]/div[@data-cc-spinner-directive="process.isLoading"]')
    select_list(:notifications_select, :xpath => '//div[@class="cc-widget cc-widget-activities ng-scope"]//select')
    unordered_list(:notifications_list, :class => 'cc-widget-activities-list')
    elements(:notification, :list_item, :xpath => '//ul[@class="cc-widget-activities-list"]/li')
    elements(:notification_toggle, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li/div')
    elements(:notification_summary, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li//strong')
    elements(:notification_source, :span, :xpath => '//ul[@class="cc-widget-activities-list"]/li//span[@data-ng-bind="activity.source"]')
    elements(:notification_date, :span, :xpath => '//ul[@class="cc-widget-activities-list"]/li//span[@data-ng-if="activity.date"]')
    elements(:notification_desc, :paragraph, :class => 'cc-widget-activities-summary')

    def wait_for_notifications(source)
      notifications_select_element.when_present timeout=WebDriverUtils.page_load_timeout
      wait_until(timeout) { notifications_select_options.include? source }
      self.notifications_select = source
    end

    def expand_notification_detail(index)
      notification_toggle_elements[index].click unless notification_desc_elements[index].visible?
    end

    def notification_more_info_link(index)
      notification_elements[index].div_element(:xpath => '//div[@data-onload="activityItem=activity"]').link_element(:xpath => '//div[@data-onload="activityItem=activity"]/a')
    end

    def expand_sub_notification_list(index)
      notification_toggle_elements[index].click unless notification_elements[index].unordered_list_element.visible?
    end

    def sub_notification_toggles(index)
      notification_elements[index].div_elements(:xpath => '//ul/li/div[@class="cc-widget-list-hover cc-widget-list-hover-notriangle"]')
    end

    def sub_notification_text(index, elements)
      elements_text = []
      expand_sub_notification_list(index)
      toggles = sub_notification_toggles(index)
      toggles.each do |toggle|
        element = elements[toggles.index(toggle)]
        toggle.click
        wait_until(WebDriverUtils.page_event_timeout) { element.visible? }
        elements_text << element.text
      end
      elements_text
    end

    def sub_notification_summaries(index)
      summary_elements = notification_elements[index].div_elements(:xpath => "//ul/li//div[contains(@class,'cc-widget-activities-sub-activity ng-binding')]")
      sub_notification_text(index, summary_elements)
    end

    def sub_notification_descrips(index)
      descrip_elements = notification_elements[index].paragraph_elements(:class => 'cc-widget-activities-sub-activity-summary')
      sub_notification_text(index, descrip_elements)
    end
  end
end
