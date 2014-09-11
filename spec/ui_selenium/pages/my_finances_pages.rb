require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  module MyFinancesPages

    include PageObject
    include CalCentralPages
    include ClassLogger

    wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
    h1(:page_heading, :xpath => '//h1[text()="My Finances"]')

    # BILLING SUMMARY CARD
    h2(:billing_summary_heading, :xpath => '//h2[text()="Billing Summary"]')
    link(:details_link, :text => 'Details')
    div(:billing_summary_spinner, :xpath => '//h2[contains(.,"Billing Summary")]/../following-sibling::div[@class="cc-spinner"]')
    paragraph(:no_cars_data_msg, :xpath => '//p[@data-ng-if="myfinancesError"]')
    unordered_list(:billing_summary_list, :xpath => '//ul[@data-ng-show="myfinances.summary"]')
    div(:dpp_balance_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppBalance"]')
    div(:dpp_normal_install_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.dppNormalInstallmentAmount"]')
    div(:dpp_text, :xpath => '//div[contains(text(),"1: Reflected in charges with DPP listed in Activity")]')
    label(:amt_due_now_label, :xpath => '//strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]/../../preceding-sibling::div/strong[1]')
    div(:amt_due_now_element, :xpath => '//div[@class="cc-page-myfinances-amount"]/strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]')
    span(:past_due_amt_element, :xpath => '//span[@data-cc-amount-directive="myfinances.summary.totalPastDueAmount"]')
    div(:charges_not_due_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.futureActivity"]')
    div(:account_balance_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.accountBalance"]')
    div(:last_statement_bal_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.lastStatementBalance"]')
    link(:make_payment_link, :xpath => '//a[@href="http://studentbilling.berkeley.edu/carsPaymentOptions.htm"]')

    def wait_for_billing_summary_card(driver)
      logger.debug('Waiting for billing summary card to load')
      wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_load_timeout)
      wait.until { driver.find_element(:xpath => '//ul[@data-ng-show="myfinances.summary"]') }
    end

    def wait_for_billing_summary(driver)
      logger.debug('Waiting for billing summary to load, spinner is still going')
      !10.times{ break unless (driver.find_element(:xpath, '//h2[contains(.,"Billing Summary")]/../following-sibling::div[@class="cc-spinner"]').displayed? rescue false); sleep 1 }
    end

    def wait_for_fin_resources_links
      fin_resources_list_element.when_visible(timeout=WebDriverUtils.fin_resources_links_timeout)
    end

    def has_no_cars_data_msg?
      if no_cars_data_msg?
        return true
      end
      false
    end

    def click_account_balance(driver)
      driver.find_element(:xpath, '//div[@data-ng-click="api.widget.toggleShow($event, null, myfinances, \'My Finances - Summary\')"]').click
      last_statement_bal_element_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
    end

    def click_details_link
      details_link
      activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
    end

    def account_balance
      account_balance_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      account_balance_element.delete('$, ')
    end

    def last_statement_balance
      last_statement_bal_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      last_statement_bal_element.delete('$, ')
    end

    def amt_due_now
      amt_due_now_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      amt_due_now_element.delete('$, ')
    end

    def past_due_amt
      past_due_amt_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      past_due_amt_element.delete('$, ')
    end

    def charges_not_due
      charges_not_due_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      charges_not_due_element.delete('$, ')
    end

    def dpp_balance
      dpp_balance_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      dpp_balance_element.delete('$, ')
    end

    def dpp_normal_install
      dpp_normal_install_element_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      dpp_normal_install_element.delete('$, ')
    end

  end
end
