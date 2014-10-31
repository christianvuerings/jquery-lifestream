require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative '../util/web_driver_utils'

class ApiMyFinAidPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/finaid')
    driver.get(WebDriverUtils.base_url + '/api/my/finaid')
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"Finaid::MyFinAid")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def title(item)
    item['title']
  end

  def summary(item)
    item['summary']
  end

  def type(item)
    item['type']
  end

  def date(item)
    item['date']
  end

  def date_str(item)
    item['date']['dateString']
  end

  def date_epoch(item)
    Time.at(item['date']['epoch'])
  end

  def term_year(item)
    item['termYear']
  end

  def all_activity
    @parsed['activities']
  end

  def undated_messages
    dateless_messages =  all_activity.select { |item| date(item) == '' }
    sorted_messages = dateless_messages.sort_by { |item| title(item)}
    sorted_messages.each { |item| logger.info("Message: #{title(item)}") }
  end

  def dated_messages
    dateful_messages = all_activity.select { |item| date(item) != ''}
    sorted_messages = dateful_messages.sort_by { |item| date_epoch(item) }
    sorted_messages.reverse!
    sorted_messages.each { |item| logger.info("Message: #{date_str(item)}") }
  end

  def all_messages_sorted
    undated_messages.push(*dated_messages)
  end

  def all_message_titles_sorted
    message_titles = []

  end

  def all_message_summaries_sorted

  end

  def all_message_types_sorted

  end

end
