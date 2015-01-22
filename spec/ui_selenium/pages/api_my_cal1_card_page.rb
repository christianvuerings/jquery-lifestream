require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative '../util/web_driver_utils'

class ApiMyCal1CardPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/cal1card')
    driver.get(WebDriverUtils.base_url + '/api/my/cal1card')
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def card_lost?
    if @parsed['cal1cardLost'] == 'Lost'
      true
    end
  end

  def card_found?
    if @parsed['cal1cardLost'] == 'Found'
      true
    end
  end

  def has_debit_account?
    if @parsed['debitMessage'] == 'OK'
      true
    end
  end

  def debit_balance
    (sprintf '%.2f', @parsed['debit'].to_f).to_s
  end

  def has_meal_plan?
    unless @parsed['mealpointsPlan'].nil?
      true
    end
  end

  def meal_points_balance
    @parsed['mealpoints']
  end

  def meal_points_plan
    @parsed['mealpointsPlan']
  end
end
