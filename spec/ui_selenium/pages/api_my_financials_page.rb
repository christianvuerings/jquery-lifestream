require 'selenium-webdriver'
require 'page-object'
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

  def trans_amt_str(item)
    (sprintf '%.2f', item['transAmount'])
  end

  def trans_balance_str(item)
    (sprintf '%.2f', item['transBalance'])
  end

  def trans_date(item)
    item['transDate']
  end

  def trans_dept(item)
    item['transDept']
  end

  def trans_dept_url(item)
    item['transDeptUrl']
  end

  def trans_desc(item)
    item['transDesc']
  end

  def trans_due_date(item)
    item['transDueDate']
  end

  def trans_id(item)
    item['transId']
  end

  def trans_status(item)
    item['transStatus']
  end

  def trans_type(item)
    item['transType']
  end

  def trans_term(item)
    item['transTerm']
  end

  def trans_disburse_date(item)
    disburse_date = item['transPotentialDisbursementDate']
    (disburse_date == '') ? nil : Date.parse(disburse_date).strftime("%m/%d/%y")
  end

  def trans_disputed(item)
    item['transDisputedFlag']
  end

  def trans_refund_method(item)
    item['transPaymentMethod']
  end

  def trans_refund_last_action_date(item)
    item['transPaymentLastActionDate']
  end

  def trans_refund_last_action(item)
    item['transPaymentLastAction']
  end

  def trans_refund_void_date(item)
    item['transPaymentVoidDate']
  end

  def all_transactions
    @parsed['activity']
  end

  def all_transactions_by_type(type)
    all_transactions.select do |item|
      trans_type(item) == type
    end
  end

  def open_transactions
    all_transactions.select do |item|
      (trans_status(item) == 'Current' || trans_status(item) == 'Past due' || trans_status(item) == 'Future' || trans_status(item) == 'Installment') && !trans_disputed(item) ||
          (trans_type(item) == 'Payment' && trans_status(item) == 'Unapplied')
    end
  end

  def open_transactions_sum
    open_transactions.inject(BigDecimal.new('0')) { |acc, bal| acc + BigDecimal.new(trans_balance_str(bal).to_s) }
  end

  def open_transactions_sum_str
    (sprintf '%.2f', self.open_transactions_sum).to_s
  end

  def open_charges
    all_transactions_by_type('Charge') & open_transactions
  end

  def past_due_charges
    open_charges.select do |item|
      trans_status(item) == 'Past due'
    end
  end

  def current_charges
    open_charges.select do |item|
      trans_status(item) == 'Current'
    end
  end

  def future_charges
    open_charges.select do |item|
      trans_status(item) == 'Future'
    end
  end

  def open_charges_sum_str
    sum = open_charges.inject(BigDecimal.new('0')) { |acc, bal| acc + BigDecimal.new(trans_balance_str(bal).to_s) }
    (sprintf '%.2f', sum).to_s
  end

  def term_transactions(term)
    all_transactions.select do |item|
      trans_term(item) == term
    end
  end

  def date_range_transactions(start_date, end_date)
    all_transactions.select do |item|
      Time.strptime(start_date, '%m/%d/%Y') <= Time.parse(trans_date(item)) && Time.strptime(end_date, '%m/%d/%Y') >= Time.parse(trans_date(item))
    end
  end

  def last_update_date_str
    @parsed['summary']['lastUpdateDate']
  end
end
