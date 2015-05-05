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
      select_list(:activity_filter_term_select, :id => 'cc-page-myfinances-select-term')
      text_area(:search_string_input, :xpath => '//input[@data-ng-model="search.$"]')
      text_area(:search_start_date_input, :id => 'cc-page-myfinances-date-start')
      text_area(:search_end_date_input, :id => 'cc-page-myfinances-date-end')
      paragraph(:search_start_date_format_error, :xpath => '//p[contains(.,"Please use mm/dd/yyyy date format for the start date.")]')
      paragraph(:search_end_date_format_error, :xpath => '//p[contains(.,"Please use mm/dd/yyyy date format for the end date.")]')

      link(:sort_by_date, :xpath => '//th[@data-ng-click="changeSorting(\'transDate\')"]')
      link(:sort_by_descrip, :xpath => '//th[@data-ng-click="changeSorting(\'transDesc\')"]')
      link(:sort_by_amount, :xpath => '//th[@data-ng-click="changeSorting(\'transBalanceAmountFloat\')"]')
      link(:sort_by_trans_type, :xpath => '//th[@data-ng-click="changeSorting(\'transType\')"]')
      link(:sort_by_due_now, :xpath => '//th[@data-ng-click="changeSorting(\'isDueNow\')"]')
      image(:sort_descending, :xpath => '//i[@class="fa fa-chevron-down"]')
      image(:sort_ascending, :xpath => '//i[@class="fa fa-chevron-up"]')

      table(:transaction_table, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table cc-table-finances"]/table')
      link(:transaction_table_row_one, :xpath => '//div[@class="cc-table cc-table-sortable cc-page-myfinances-table cc-table-finances"]/table/tbody')

      span(:trans_date, :xpath => '//span[@data-ng-bind="item.transDate | date:\'MM/dd/yy\'"]')
      div(:trans_desc, :xpath => '//div[@data-ng-bind="item.transDesc"]')
      td(:trans_amt, :xpath => '//td[@data-cc-amount-directive="item.transBalanceAmount"]')
      span(:trans_type, :xpath => '//span[@data-ng-bind="item.transType"]')
      image(:trans_due_future_icon, :xpath => '//i[@class="fa ng-scope fa-arrow-right"]')
      image(:trans_due_now_icon, :xpath => '//i[@class="fa ng-scope fa-exclamation"]')
      image(:trans_due_past_icon, :xpath => '//i[@class="fa ng-scope fa-exclamation-circle cc-icon-red"]')
      div(:trans_id, :xpath => '//div[@data-ng-if="item.transId"]')
      div(:trans_orig_amt, :xpath => '//div[@data-ng-if="item.originalAmount"]')
      div(:trans_due_date, :xpath => '//div[@data-ng-if="item.transDueDateShow && !(item.transStatus === \'Closed\' && item.transType === \'Refund\')"]')
      div(:trans_dept, :xpath => '//div[@data-ng-if="item.transDept"]')
      div(:trans_term, :xpath => '//div[@data-ng-if="item.transTerm"]')
      div(:trans_disburse_date, :xpath => '//div[@data-ng-if="item.transPotentialDisbursementDate"]')
      div(:trans_ref_method, :xpath => '//div[@data-ng-if="item.transPaymentMethod"]')
      div(:trans_ref_date, :xpath => '//div[@data-ng-if="item.transPaymentLastActionDate"]')
      div(:trans_ref_action, :xpath => '//div[@data-ng-if="item.transPaymentLastAction"]')
      div(:trans_ref_void, :xpath => '//div[@data-ng-if="item.transPaymentVoidDate"]')
      div(:trans_unapplied, :xpath => '//div[@data-ng-if="item.transStatus === \'Unapplied\' && item.transType === \'Award\'"]')

      paragraph(:zero_balance_text, :xpath => '//p[contains(text(),"You do not owe anything at this time. Please select a different filter to view activity details.")]')
      paragraph(:credit_balance_text, :xpath => '//p[contains(text(),"You have an over-payment on your account. You do not owe anything at this time. Please select a different filter to view activity details.")]')

      button(:show_more_button, :xpath => '//button[@class="cc-button cc-widget-show-more"]')

      span(:last_update_date, :xpath => '//span[@data-ng-bind="myfinances.summary.lastUpdateDate | date:\'MM/dd/yy\'"]')

      def load_page(driver)
        logger.info('Loading My Finances details page')
        driver.get(WebDriverUtils.base_url + '/finances/details')
        if activity_spinner_element.visible?
          activity_spinner_element.when_not_visible(timeout=WebDriverUtils.financials_timeout)
        end
      end

      # VISIBLE TRANSACTIONS

      def visible_transaction_count
        transaction_table_element.rows - 1
      end

      def visible_transaction_dates
        date_strings = []
        transaction_table_element.each { |row| date_strings.push(row[0].text) }
        dates_minus_heading = date_strings.drop(1)
        dates = []
        dates_minus_heading.each { |date| dates.push(Time.strptime(date, '%m/%d/%y')) }
        dates
      end

      def visible_transaction_descrip
        descriptions = Array.new
        transaction_table_element.each do |row|
          description = row[1].text
          descriptions.push(description)
        end
        descriptions.drop(1)
      end

      def visible_transaction_amts_str
        amounts = Array.new
        transaction_table_element.each do |row|
          amount = row[2].text.delete('$, ')
          amounts.push(amount)
        end
        amounts.drop(1)
      end

      def visible_transaction_amts
        visible_transaction_amts_str.collect { |s| s.to_f }
      end

      def visible_transactions_sum_str
        sum = visible_transaction_amts_str.inject(BigDecimal.new('0')) { |acc, amt| acc + BigDecimal.new(amt) }
        (sprintf '%.2f', sum).to_s
      end

      def visible_transaction_types
        trans_types = Array.new
        transaction_table_element.each do |row|
          trans_type = row[4].text
          trans_types.push(trans_type)
        end
        trans_types.drop(1)
      end

      def keep_showing_more
        while show_more_button_element.visible?
          show_more_button
        end
      end

      def toggle_first_trans_detail
        transaction_table_row_one
      end

      # TRANSACTION FILTERING

      def select_transactions_filter(filter)
        logger.debug('Filtering by ' + filter)
        wait_until(timeout=WebDriverUtils.page_event_timeout, nil) { self.activity_filter_select != '' }
        self.activity_filter_select = filter
      end

      def select_term_filter(term)
        logger.debug('Filtering by ' + term)
        self.activity_filter_term_select = term
      end

      def enter_search_start_date(date)
        logger.debug('Search start date is ' + date)
        search_start_date_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        self.search_start_date_input = date
      end

      def enter_search_end_date(date)
        logger.debug('Search end date is ' + date)
        search_end_date_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        self.search_end_date_input = date
      end

      def enter_search_string(string)
        logger.debug('Searching for "' + string + '"')
        search_string_input_element.when_visible(timeout=WebDriverUtils.page_event_timeout)
        self.search_string_input = string
      end

      def search_by_dates_and_string(start_date, end_date, string)
        enter_search_start_date(start_date)
        enter_search_end_date(end_date)
        enter_search_string(string)
      end

      # TRANSACTION SORTING

      def sort_by_date_asc
        logger.info('Sorting by date ascending')
        sort_by_date
        if sort_descending?
          sort_by_date
        end
      end

      def sort_by_date_desc
        logger.info('Sorting by date descending')
        sort_by_date
        if sort_ascending?
          sort_by_date
        end
      end

      def sort_by_descrip_asc
        logger.info('Sorting by description ascending')
        sort_by_descrip
        if sort_descending?
          sort_by_descrip
        end
      end

      def sort_by_descrip_desc
        logger.info('Sorting by description descending')
        sort_by_descrip
        if sort_ascending?
          sort_by_descrip
        end
      end

      def sort_by_amount_asc
        logger.info('Sorting by amount ascending')
        sort_by_amount
        if sort_descending?
          sort_by_amount
        end
      end

      def sort_by_amount_desc
        logger.info('Sorting by amount descending')
        sort_by_amount
        if sort_ascending?
          sort_by_amount
        end
      end

      def sort_by_trans_type_asc
        logger.info('Sorting by transaction type ascending')
        sort_by_trans_type
        if sort_descending?
          sort_by_trans_type
        end
      end

      def sort_by_trans_type_desc
        logger.info('Sorting by transaction type descending')
        sort_by_trans_type
        if sort_ascending?
          sort_by_trans_type
        end
      end
    end
  end
end
