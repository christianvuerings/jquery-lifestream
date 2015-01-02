require 'selenium-webdriver'
require 'page-object'
require_relative '../util/web_driver_utils'

class ApiMyAdvisingPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/advising')
    driver.get(WebDriverUtils.base_url + '/api/my/advising')
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.academics_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"Advising::MyAdvising")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def college_advisor
    @parsed['caseloadAdviser']['firstName'] + @parsed['caseloadAdviser']['lastName']
  end

  def all_future_appts
    @parsed['futureAppointments']
  end

  def all_future_appt_dates
    dates = []
      all_future_appts.each { |date| dates.push(date[]) }
    dates
  end

  def all_future_appt_times
    times = []

    times
  end

  def all_future_appt_advisors
    advisors = []
      all_future_appts.each { |advisor| advisors.push(advisor['staff']['name']) }
    advisors
  end

  def all_future_appt_methods
    methods = []
      all_future_appts.each { |method| methods.push(method['method']) }
    methods
  end

  def all_future_appt_locations
    locations = []
      all_future_appts.each { |location| locations.push(location['location']) }
    locations
  end

  def all_past_appts
    @parsed['pastAppointments']
  end

  def all_past_appt_dates
    dates = []
    all_past_appts.each { |date| dates.push(date['dateTime'].(Time.strptime(epoch, '%s')).strftime("%m/%d/%y")) }
    dates
  end

  def all_past_appt_advisors
    names = []
    all_past_appts.each { |name| names.push(name['name']) }
    names
  end

end
