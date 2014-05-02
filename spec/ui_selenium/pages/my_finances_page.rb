require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

class CalCentralPages::MyFinancesPage

  include PageObject
  include CalCentralPages

  wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
  h1(:page_heading, :xpath => '//h1[text()="My Finances"]')

  # BILLING SUMMARY CARD
  h2(:billing_summary_heading, :xpath => '//h2[text()="Billing Summary"]')
  unordered_list(:billing_summary_list, :xpath => '//ul[@data-ng-show="myfinances.summary"]')
  div(:account_balance_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.accountBalance"]')
  div(:last_statement_bal_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.lastStatementBalance"]')
  div(:amt_due_now_element, :xpath => '//div[@class="cc-page-myfinances-amount"]/strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]')
  label(:amt_due_now_label, :xpath => '//strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]/../../preceding-sibling::div/strong[1]')
  span(:past_due_amt_element, :xpath => '//span[@data-cc-amount-directive="myfinances.summary.totalPastDueAmount"]')
  div(:dpp_balance_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppBalance"]')
  div(:dpp_normal_install_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppNormalInstallmentAmount"]')
  div(:dpp_text, :xpath => '//div[contains(text(),"1: Reflected in charges with DPP listed in Activity")]')
  link(:make_payment_link, :xpath => '//a[@href="http://studentbilling.berkeley.edu/carsPaymentOptions.htm"]')
  link(:details_link, :text => 'Details')

  # CAL 1 CARD CARD
  h2(:cal_1_card_heading, :xpath => '//h2[text()="Cal 1 Card"]')

  # FINANCIAL RESOURCES CARD
  h2(:fin_resources_heading, :xpath => '//h2[text()="Financial Resources"]')
  div(:fin_resources_spinner, :xpath => '//h2[text()="Financial Resources"]/../following-sibling::div[@class="cc-spinner"]')
  unordered_list(:fin_resources_list, :xpath => '//ul[@class="cc-list-links"]')
  link(:cal_student_central_link, :xpath => '//a[contains(.,"Cal Student Central")]')
  link(:fin_aid_estimator_link, :xpath => '//a[contains(.,"Financial Aid Estimator")]')
  link(:reg_fees_link, :xpath => '//a[contains(.,"Registration Fees")]')
  link(:student_billing_svcs_link, :xpath => '//a[contains(.,"Student Billing Services")]')
  link(:student_budgets_link, :xpath => '//a[contains(.,"Student Budgets")]''')
  link(:educ_loan_counseling_link, :xpath => '//a[contains(.,"Education loan counseling")]')
  link(:fafsa_link, :xpath => '//a[contains(.,"FAFSA")]')
  link(:fin_aid_link, :xpath => '//a[contains(.,"Financial Aid")]')
  link(:my_fin_aid_link, :xpath => '//a[contains(.,"MyFinAid")]')
  link(:grad_loans_link, :xpath => '//a[contains(.,"Grad Loans")]')
  link(:grad_student_fin_support_link, :xpath => '//a[contains(.,"Graduate Student Financial Support")]')
  link(:scholarship_db_link, :xpath => '//a[contains(.,"Scholarship database")]')
  link(:undergrad_fin_facts_link, :xpath => '//a[contains(.,"Undergrad Financial Facts")]')
  link(:undergrad_loans_link, :xpath => '//a[contains(.,"Undergrad Loans")]')

  # FINANCIAL MESSAGES CARD
  h2(:fin_messages_heading, :xpath => '//h2[text()="Financial Messages"]')

  # ACTIVITY CARD
  h2(:activity_heading, :xpath => '//h2[text()="Activity"]')
  div(:activity_table, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table"]')

  def load_page(driver)
    driver.get(WebDriverUtils.base_url + '/finances')
  end

  def wait_for_page_heading
    page_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
  end

  def wait_for_billing_summary
    billing_summary_list_element.when_visible(timeout=WebDriverUtils.financials_timeout)
  end

  def wait_for_fin_resources_links
    fin_resources_list_element.when_visible(timeout=WebDriverUtils.fin_resources_links_timeout)
  end

  def click_account_balance(driver)
    driver.find_element(:xpath, '//div[@data-ng-click="api.widget.toggleShow($event, null, myfinances, \'My Finances - Summary\')"]').click
  end

  def click_details_link
    details_link
    activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
  end

  def account_balance
    account_balance_element.delete('$, ')
  end

  def last_statement_balance
    last_statement_bal_element.delete('$, ')
  end

  def amt_due_now
    amt_due_now_element.delete('$, ')
  end

  def past_due_amt
    past_due_amt_element.delete('$, ')
  end

  def dpp_balance
    dpp_balance_element.delete('$, ')
  end

  def dpp_normal_install
    dpp_normal_install_element.delete('$, ')
  end

end