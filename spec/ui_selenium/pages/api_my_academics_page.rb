require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class ApiMyAcademicsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/academics')
    driver.get(WebDriverUtils.base_url + '/api/my/academics')
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.academics_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"MyAcademics::Merged")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def active_blocks
    @parsed['regblocks']['activeBlocks']
  end

  def inactive_blocks
    @parsed['regblocks']['inactiveBlocks']
  end

  def block_type(item)
    item['type']
  end

  def block_reason(item)
    item['reason']
  end

  def block_office(item)
    item['office']
  end

  def block_date(item)
    item['blockedDate']['dateString']
  end

  def block_message(item)
    item['message']
  end

  def block_cleared_date(item)
    item['clearedDate']['dateString']
  end

  def active_block_types
    types = []
    active_blocks.select do |item|
      type = block_type(item)
      types.push(type)
    end
    types
  end

  def active_block_reasons
    reasons = []
    active_blocks.select do |item|
      reason = block_reason(item)
      reasons.push(reason)
    end
    reasons
  end

  def active_block_offices
    offices = []
    active_blocks.select do |item|
      office = block_office(item)
      offices.push(office)
    end
    offices
  end

  def active_block_dates
    dates = []
    active_blocks.select do |item|
      date = (Time.strptime(block_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end

  def inactive_block_types
    types = []
    inactive_blocks.select do |item|
      type = block_type(item)
      types.push(type)
    end
    types
  end

  def inactive_block_dates
    dates = []
    inactive_blocks.select do |item|
      date = (Time.strptime(block_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end

  def inactive_block_cleared_dates
    dates = []
    inactive_blocks.select do |item|
      date = (Time.strptime(block_cleared_date(item), '%m/%d/%Y')).strftime('%m/%d/%y')
      dates.push(date)
    end
    dates
  end
end
