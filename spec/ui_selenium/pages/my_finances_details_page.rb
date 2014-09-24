require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_finances_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  module MyFinancesPages
    class MyFinancesDetailsPage

      include PageObject
      include CalCentralPages
      include MyFinancesPages
      include ClassLogger

      wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
      h1(:page_heading, :xpath => '//h1[contains(.,"Details"]')
      div(:activity_spinner, :xpath => '//h2[text()="Activity"]/../following-sibling::div[@class="cc-spinner"]')

      select_list(:activity_filter_select, :id => 'cc-page-myfinances-account-choices')
      select_list(:activity_filter_term_select , :id => 'cc-page-myfinances-select-term')
      text_area(:search_string_input, :xpath => '//input[@data-ng-model="search.$"]')
      text_area(:search_start_date_input, :id => 'cc-page-myfinances-date-start')
      text_area(:search_end_date_input, :id => 'cc-page-myfinances-date-end')

      link(:sort_by_date, :xpath => '//th[@data-ng-click="changeSorting(\'transDate\')"]')
      link(:sort_by_desc, :xpath => '//th[@data-ng-click="changeSorting(\'transDesc\')"]')
      link(:sort_by_amount, :xpath => '//th[@data-ng-click="changeSorting(\'transBalanceAmountFloat\')"]')
      link(:sort_by_trans_type, :xpath => '//th[@data-ng-click="changeSorting(\'transType\')"]')
      link(:sort_by_due_now, :xpath => '//th[@data-ng-click="changeSorting(\'isDueNow\')"]')

      table(:transaction_table, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table"]/table')

      paragraph(:zero_balance_text, :xpath => '//p[contains(text(),"You do not owe anything at this time. Please select a different filter to view activity details.")]')
      paragraph(:credit_balance_text, :xpath => '//p[contains(text(),"You have an over-payment on your account. You do not owe anything at this time. Please select a different filter to view activity details.")]')

      span(:last_update_date, :xpath => '//span[@data-ng-bind="myfinances.summary.lastUpdateDate | date:\'MM/dd/yy\'"]')


      def load_page(driver)
        logger.info('Loading My Finances details page')
        driver.get(WebDriverUtils.base_url + '/finances/details')
        if activity_spinner_element.visible?
          activity_spinner_element.when_not_visible(timeout=WebDriverUtils.financials_timeout)
        end
      end

      def select_transactions_filter(filter)
        logger.info('Filtering by ' + filter)
        self.activity_filter_select = filter
      end

      def visible_transactions
        amounts = Array.new
        transaction_table_element.each do |row|
          amount = row[2].text.delete('$, ')
          amounts.push(amount)
        end
        amounts.drop(1)
      end

      def visible_transactions_sum_str
        sum = transactions.inject(BigDecimal.new('0')) { |acc, amt| acc + BigDecimal.new(amt) }
        (sprintf '%.2f', sum).to_s
      end
    end
  end
end
