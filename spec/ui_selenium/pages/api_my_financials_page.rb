require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative '../util/web_driver_utils'

class ApiMyFinancialsPage

  include PageObject
  include ClassLogger

  def get_json(driver)
    logger.info('Parsing JSON from /api/my/financials')
    driver.get(WebDriverUtils.base_url + '/api/my/financials')
    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
    wait.until { driver.find_element(:xpath => '//pre[contains(.,"Financials::MyFinancials")]') }
    body = driver.find_element(:xpath, '//pre').text
    @parsed = JSON.parse(body)
  end

  def has_cars_data?
    if @parsed['statusCode'] == 400 || @parsed['statusCode'] == 404
      logger.info('User has no CARS data')
      return false
    end
    true
  end

  def account_balance
    @parsed['summary']['accountBalance']
  end

  def account_balance_str
    (sprintf '%.2f', self.account_balance).to_s
  end

  def last_statement_balance_str
    last_statement_balance = @parsed['summary']['lastStatementBalance']
    (sprintf '%.2f', last_statement_balance).to_s
  end

  def min_amt_due
    @parsed['summary']['minimumAmountDue']
  end

  def min_amt_due_str
    (sprintf '%.2f', self.min_amt_due).to_s
  end

  def total_current_balance
    @parsed['summary']['totalCurrentBalance']
  end

  def total_current_balance_str
    (sprintf '%.2f', self.total_current_balance).to_s
  end

  def past_due_amt
    @parsed['summary']['totalPastDueAmount']
  end

  def past_due_amt_str
    (sprintf '%.2f', self.past_due_amt).to_s
  end

  def future_activity
    @parsed['summary']['futureActivity']
  end

  def future_activity_str
    (sprintf '%.2f', self.future_activity).to_s
  end

  def is_on_dpp?
    @parsed['summary']['isOnDPP']
  end

  def is_dpp_past_due?
    @parsed['summary']['isDppPastDue']
  end

  def dpp_balance
    @parsed['summary']['dppBalance']
  end

  def dpp_balance_str
    (sprintf '%.2f', self.dpp_balance).to_s
  end

  def dpp_norm_install_amt
    @parsed['summary']['dppNormalInstallmentAmount']
  end

  def dpp_norm_install_amt_str
    (sprintf '%.2f', self.dpp_norm_install_amt).to_s
  end

  def all_transactions
    @parsed['activity']
  end

  def open_transactions
    all_transactions.select do |item|
      ((item['transStatus'] == 'Current' || item['transStatus'] == 'Past due' || item['transStatus'] == 'Future' || item['transStatus'] == 'Installment') && !item['transDisputedFlag']) ||
      (item['transType'] == 'Payment' && item['transStatus'] == 'Unapplied')
    end
  end

  def open_transactions_sum
    open_transactions.inject(BigDecimal.new('0')) { |acc, bal| acc + BigDecimal.new(bal['transBalance'].to_s) }
  end

  def open_transactions_sum_str
    (sprintf '%.2f', self.open_transactions_sum).to_s
  end

  def open_charges
    all_transactions.select do |item|
      (item['transStatus'] == 'Current' || item['transStatus'] == 'Past due' || item['transStatus'] == 'Future' || item['transStatus'] == 'Installment') && !item['transDisputedFlag']
    end
  end

  def term_transactions(term)
    all_transactions.select do |item|
      item['transTerm'] == term
    end
  end

  def date_range_transactions(start_date, end_date)
    all_transactions.select do |item|
      Time.strptime(start_date, '%m/%d/%Y') <= Time.parse(item['transDate']) && Time.strptime(end_date, '%m/%d/%Y') >= Time.parse(item['transDate'])
    end
  end

  def last_update_date_str
    @parsed['summary']['lastUpdateDate']
  end
end
