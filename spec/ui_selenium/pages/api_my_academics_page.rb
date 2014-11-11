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

  # BLOCKS

  def has_no_standing
    @parsed['collegeAndLevel']['empty']
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

  # TELE-BEARS

  def has_tele_bears
    begin
      tele_bears_phases.length > 0
      true
    rescue
      false
    end
  end

  def tele_bears_term_year
    @parsed['telebears']['term'] + ' ' + @parsed['telebears']['year'].to_s
  end

  def tele_bears_code_required
    @parsed['telebears']['adviserCodeRequired']['required']
  end

  def tele_bears_code_message
    @parsed['telebears']['adviserCodeRequired']['message']
  end

  def tele_bears_phases
    @parsed['telebears']['phases']
  end

  def tele_bears_phase_period(phase)
    phase['period']
  end

  def tele_bears_date_time(epoch)
    date = (Time.strptime(epoch, '%s')).strftime("%a %b %-d")
    time = (Time.strptime(epoch, '%s')).strftime("%-l:%M %p")
    if time == '12:00 PM'
      date_time = date + ' | ' + 'Noon'
    else
      date_time = date + ' | ' + time
    end
    date_time
  end

  def tele_bears_phase_start(phase)
    epoch = phase['startTime']['epoch'].to_s
    tele_bears_date_time(epoch)
  end

  def tele_bears_phase_end(phase)
    epoch = phase['endTime']['epoch'].to_s
    tele_bears_date_time(epoch)
  end
end
