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
    div(:dpp_text, :xpath => '//div[contains(text(),"1: Reflected in charges with DPP")]')
    label(:amt_due_now_label, :xpath => '//strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]/../../preceding-sibling::div/strong[1]')
    div(:amt_due_now_element, :xpath => '//div[@class="cc-page-myfinances-amount"]/strong[@data-cc-amount-directive="myfinances.summary.minimumAmountDue"]')
    span(:past_due_amt_element, :xpath => '//span[@data-cc-amount-directive="myfinances.summary.totalPastDueAmount"]')
    div(:charges_not_due_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.futureActivity"]')
    div(:account_balance_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.accountBalance"]')
    link(:toggle_last_statement_bal, :xpath => '//div[@data-ng-click="api.widget.toggleShow($event, null, myfinances, \'My Finances - Summary\')"]')
    div(:last_statement_bal_element, :xpath => '//div[@data-cc-amount-directive="myfinances.summary.lastStatementBalance"]')
    link(:view_statements_link, :xpath => '//a[contains(text(),"View Statements")]')
    link(:make_payment_link, :xpath => '//a[@href="http://studentbilling.berkeley.edu/carsPaymentOptions.htm"]')

    def show_last_statement_bal
      unless last_statement_bal_element_element.visible?
        toggle_last_statement_bal
        last_statement_bal_element_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
      end
    end

    def hide_last_statement_bal
      if last_statement_bal_element_element.visible?
        toggle_last_statement_bal
        last_statement_bal_element_element.when_not_visible(timeout=WebDriverUtils.page_event_timeout)
      end
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
