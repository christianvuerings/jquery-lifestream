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

  def tele_bears
    @parsed['telebears']
  end

  def has_tele_bears
    begin
      tele_bears.length > 0
      true
    rescue
      false
    end
  end

  def tele_bears_phases(semesters)
    all_phases = []
    semesters.each { |semester| all_phases.concat(semester['phases']) }
    all_phases
  end

  def tele_bears_term_year(semester)
    semester['term'] + ' ' + semester['year'].to_s
  end

  def tele_bears_term_years(semesters)
    term_years = []
    semesters.each { |semester| term_years.concat(semester['term'] + ' ' + semester['year'].to_s) }
    term_years
  end

  def tele_bears_semester_slug(semester)
    semester['slug']
  end

  def tele_bears_adviser_codes(semesters)
    code_reqts = []
    semesters.each { |semester| code_reqts.push(semester['adviserCodeRequired']['required']) }
    code_reqts
  end

  def tele_bears_adviser_code_msgs(semesters)
    code_msgs = []
    semesters.each { |semester| code_msgs.push(semester['adviserCodeRequired']['message']) }
    code_msgs
  end

  def tele_bears_phase_starts(semesters)
    epochs = []
    tele_bears_phases(semesters).each { |item| epochs.push(item['startTime']['epoch'].to_s) }
    phase_starts = []
    epochs.each { |epoch| phase_starts.push(tele_bears_date_time(epoch)) }
    phase_starts
  end

  def tele_bears_phase_endings(semesters)
    epochs = []
    tele_bears_phases(semesters).each { |item| epochs.push(item['endTime']['epoch'].to_s) }
    phase_ends = []
    epochs.each { |item| phase_ends.push(tele_bears_date_time(item)) }
    phase_ends
  end

  def tele_bears_date_time(epoch)
    date = (Time.strptime(epoch, '%s')).strftime("%a %b %-d")
    # date = epoch.strftime("%a %b %-d")
    # time = epoch.strftime("%-l:%M %p")
    time = (Time.strptime(epoch, '%s')).strftime("%-l:%M %p")
    if time == '12:00 PM'
      date_time = date + ' | ' + 'Noon'
    else
      date_time = date + ' | ' + time
    end
    date_time
  end
end
