require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class ApiMyAdvisingPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/advising')
    navigate_to "#{WebDriverUtils.base_url}/api/my/advising"
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.academics_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"Advising::MyAdvising")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def college_advisor
    if @parsed['caseloadAdvisor'] == ''
      nil
    else
      @parsed['caseloadAdvisor']['firstName'].to_s + ' ' + @parsed['caseloadAdvisor']['lastName'].to_s
    end
  end

  def all_future_appts
    @parsed['futureAppointments']
  end

  def all_future_appt_epochs
    epochs = []
    all_future_appts.each { |appt| epochs.push((appt['dateTime'] / 1000).to_s) }
    epochs
  end

  def all_future_appt_dates
    dates = []
    all_future_appt_epochs.each { |epoch| dates.push(WebDriverUtils.ui_numeric_date_format(Time.strptime(epoch, '%s'))) }
    dates
  end

  def all_future_appt_times
    times = []
    all_future_appt_epochs.each do |epoch|
      time_format = (Time.strptime(epoch, '%s')).strftime("%-l:%M %p")
      if time_format == '12:00 PM'
        time = 'Noon'
      else
        time = time_format
      end
      times.push(time)
    end
    times
  end

  def all_future_appt_advisors
    advisors = []
    all_future_appts.each { |appt| advisors.push(appt['staff']['name']) }
    advisors
  end

  def all_future_appt_methods
    methods = []
    all_future_appts.each { |appt| methods.push(appt['method'].upcase) }
    methods
  end

  def all_future_appt_locations
    locations = []
    all_future_appts.each { |appt| locations.push(appt['location'].gsub("  ", " ").upcase) }
    locations
  end

  def all_prev_appts
    @parsed['pastAppointments']
  end

  def all_prev_appt_dates
    dates = []
    all_prev_appts.each { |appt| dates.push((Time.strptime((appt['dateTime'] / 1000).to_s, '%s')).strftime("%m/%d/%y")) }
    dates
  end

  def all_prev_appt_advisors
    names = []
    all_prev_appts.each { |name| names.push(name['staff']['name']) }
    names
  end

end
