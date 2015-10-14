require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  class MyDashboardUpNextCard < MyDashboardPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    span(:day, :xpath => '//span[@data-ng-bind="lastModifiedDate | date:\'EEEE\'"]')
    span(:date, :xpath => '//span[@data-ng-bind="lastModifiedDate | date:\'MMM d\'"]')
    unordered_list(:events_list, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]')
    elements(:event_time, :div, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//div[@class="cc-widget-mycalendar-datelist-time cc-left"]')
    elements(:event_summary, :div, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//strong[@data-ng-bind="item.summary"]')
    elements(:event_location, :div, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//div[@data-ng-bind="item.location"]')
    elements(:event_detail_toggle, :div, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//div[@data-ng-click="api.widget.toggleShow($event, items, item, \'Up Next\')"]')
    div(:event_expanded_detail, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//div[@data-ng-if="item.show"]')
    div(:hangout_link, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]/li//a[contains(.,"Join Hangout")]')
    div(:event_start_time, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]//div[@data-ng-bind="item.start.epoch * 1000 | date:\'short\' | lowercase"]')
    div(:event_end_time, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]//div[@data-ng-bind="item.end.epoch * 1000 | date:\'short\' | lowercase"]')
    paragraph(:event_organizer, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]//p[@data-ng-bind="item.organizer"]')
    link(:view_in_bcal_button, :xpath => '//ul[@class="cc-widget-list cc-widget-mycalendar-datelist"]//a[contains(.,"View in bCal")]')

    def expand_event_detail(toggle_element)
      begin
        toggle_element.click
        event_expanded_detail_element.when_present(timeout=WebDriverUtils.page_event_timeout)
      rescue
        retry
      end
    end

    def all_event_times
      times = []
      event_time_elements.each { |time| times.push(time.text) }
      times.sort
    end

    def all_event_summaries
      summaries = []
      event_summary_elements.each { |summary| summaries.push(summary.text) }
      summaries.sort
    end

    def all_event_locations
      locations = []
      event_location_elements.each { |location| locations.push(location.text) }
      locations.sort
    end

    def hangout_link_count
      links = []
      event_detail_toggle_elements.each do |toggle|
        expand_event_detail(toggle)
        hangout_link_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        links.push(hangout_link)
        toggle.click
        hangout_link_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
      end
      links.length
    end

    def all_event_start_times
      start_times = []
      event_detail_toggle_elements.each do |toggle|
        expand_event_detail(toggle)
        event_start_time_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        start_times.push(event_start_time.gsub('  ', ' '))
        toggle.click
        event_start_time_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
      end
      start_times.sort
    end

    def all_event_end_times
      end_times = []
      event_detail_toggle_elements.each do |toggle|
        expand_event_detail(toggle)
        event_end_time_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        end_times.push(event_end_time.gsub('  ', ' '))
        toggle.click
        event_end_time_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
      end
      end_times.sort
    end

    def all_event_organizers
      organizers = []
      event_detail_toggle_elements.each do |toggle|
        expand_event_detail(toggle)
        event_organizer_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        organizers.push(event_organizer)
        toggle.click
        event_organizer_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
      end
      organizers.sort
    end

    def click_bcal_link(id)
      div_element(:xpath, "//ul[@class='cc-widget-list cc-widget-mycalendar-datelist']//span[contains(.,'#{id}')]//following-sibling::div").click
      WebDriverUtils.wait_for_element_and_click view_in_bcal_button_element
    end
  end
end
