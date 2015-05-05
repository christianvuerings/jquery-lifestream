require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/api_my_financials_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_details_page'

describe 'My Finances details page', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.page_event_timeout)

    before(:all) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    before(:context) do
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button
      @cal_net_page = CalNetAuthPage.new(@driver)
      @cal_net_page.login(UserUtils.oski_username, UserUtils.oski_password)
      @my_dashboard_page = CalCentralPages::MyDashboardPage.new(@driver)
      @my_dashboard_page.my_finances_link_element.when_visible(WebDriverUtils.page_load_timeout)
      @fin_api_page = ApiMyFinancialsPage.new(@driver)
      @fin_api_page.get_json(@driver)
      @my_finances_details_page = CalCentralPages::MyFinancesPages::MyFinancesDetailsPage.new(@driver)
      @my_finances_details_page.load_page(@driver)
      @my_finances_details_page.wait_for_billing_summary(@driver)
    end

    context 'activity card' do

      context 'transaction filters' do
        it 'allow a user to filter for open charges' do
          @my_finances_details_page.select_transactions_filter('Balance')
          @my_finances_details_page.enter_search_string('')
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.open_charges.length }
        end
        it 'allow a user to filter for open charges containing a specified string' do
          if @fin_api_page.open_charges.length > 0
            transaction = @fin_api_page.open_transactions.last
            search_string = @fin_api_page.trans_id(transaction)
            @my_finances_details_page.select_transactions_filter('Balance')
            @my_finances_details_page.enter_search_string(search_string)
            wait.until { @my_finances_details_page.visible_transaction_count == 1 }
            expect(@my_finances_details_page.show_more_button?).to be false
          end
        end
        it 'allow a user to see all transactions' do
          @my_finances_details_page.select_transactions_filter('All Transactions')
          @my_finances_details_page.enter_search_string('')
          @my_finances_details_page.keep_showing_more
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.all_transactions.length }
        end
        it 'allow a user to filter all transactions by a specified string' do
          transaction = @fin_api_page.all_transactions.last
          search_string = @fin_api_page.trans_id(transaction)
          @my_finances_details_page.select_transactions_filter('All Transactions')
          @my_finances_details_page.enter_search_string(search_string)
          wait.until { @my_finances_details_page.visible_transaction_count == 1 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'allow a user to filter all transactions by a specific term' do
          transaction = @fin_api_page.all_transactions.last
          term = @fin_api_page.trans_term(transaction)
          @my_finances_details_page.select_transactions_filter('Term')
          @my_finances_details_page.select_term_filter(term)
          @my_finances_details_page.enter_search_string('')
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.term_transactions(term).length }
        end
        it 'allow a user to filter all transactions by a specific term and a specified string' do
          transaction = @fin_api_page.all_transactions.last
          search_string = @fin_api_page.trans_id(transaction)
          search_term = @fin_api_page.trans_term(transaction)
          @my_finances_details_page.select_transactions_filter('Term')
          @my_finances_details_page.select_term_filter(search_term)
          @my_finances_details_page.enter_search_string(search_string)
          wait.until { @my_finances_details_page.visible_transaction_count == 1 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'allow a user to filter all transactions by a date range' do
          transaction = @fin_api_page.all_transactions.last
          date = Time.parse(@fin_api_page.trans_date(transaction)).strftime('%m/%d/%Y')
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date(date)
          @my_finances_details_page.enter_search_end_date(date)
          @my_finances_details_page.enter_search_string('')
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.date_range_transactions(date, date).length }
        end
        it 'allow a user to filter all transactions by a start date only' do
          transaction = @fin_api_page.all_transactions.last
          date = Time.parse(@fin_api_page.trans_date(transaction)).strftime('%m/%d/%Y')
          end_of_time = ('12/31/2100')
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date(date)
          @my_finances_details_page.enter_search_end_date('')
          @my_finances_details_page.enter_search_string('')
          @my_finances_details_page.keep_showing_more
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.date_range_transactions(date, end_of_time).length }
        end
        it 'allow a user to filter all transactions by an end date only' do
          transaction = @fin_api_page.all_transactions.last
          date = Time.parse(@fin_api_page.trans_date(transaction))
          end_date = date.strftime('%m/%d/%Y')
          beginning_of_time = '01/01/2000'
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date('')
          @my_finances_details_page.enter_search_end_date(end_date)
          @my_finances_details_page.enter_search_string('')
          @my_finances_details_page.keep_showing_more
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.date_range_transactions(beginning_of_time, end_date).length }
        end
        it 'allow a user to filter all transactions by a date range and a specified string' do
          transaction = @fin_api_page.all_transactions.last
          date = Time.parse(@fin_api_page.trans_date(transaction)).strftime('%m/%d/%Y')
          search_string = @fin_api_page.trans_id(transaction)
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date(date)
          @my_finances_details_page.enter_search_end_date(date)
          @my_finances_details_page.enter_search_string(search_string)
          wait.until { @my_finances_details_page.visible_transaction_count == 1 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'filter transactions by balance due by default' do
          @my_finances_details_page.load_page(@driver)
          @my_finances_details_page.activity_filter_select.should eql('Balance')
        end
        it 'show no results when filtered by a string that does not exist' do
          @my_finances_details_page.select_transactions_filter('All Transactions')
          @my_finances_details_page.enter_search_string('XXXXXXXXXXXXXXX')
          wait.until { @my_finances_details_page.visible_transaction_count == 0 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'show no results when filtered by a date range that does not exist among transactions' do
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date('01/01/1900')
          @my_finances_details_page.enter_search_end_date('12/31/1900')
          wait.until { @my_finances_details_page.visible_transaction_count == 0 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'show no results when filtered by an illogical date range' do
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date('01/01/1900')
          @my_finances_details_page.enter_search_end_date('01/01/1902')
          wait.until { @my_finances_details_page.visible_transaction_count == 0 }
          expect(@my_finances_details_page.show_more_button?).to be false
        end
        it 'show a validation error if a date range is in the wrong date format' do
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date('01/01/14')
          wait.until { @my_finances_details_page.search_start_date_format_error_element.visible? }
          @my_finances_details_page.enter_search_end_date('01/02/14')
          wait.until { @my_finances_details_page.search_end_date_format_error_element.visible? }
        end
      end

      context 'transaction columns' do
        before(:all) do
          today = Date.today.strftime('%m/%d/%Y')
          ninety_days_ago = (Date.today - 90).strftime('%m/%d/%Y')
          @my_finances_details_page.load_page(@driver)
          @my_finances_details_page.select_transactions_filter('Date Range')
          @my_finances_details_page.enter_search_start_date(ninety_days_ago)
          @my_finances_details_page.enter_search_end_date(today)
          wait.until { @my_finances_details_page.visible_transaction_count == @fin_api_page.date_range_transactions(ninety_days_ago, today).length }
        end
        it 'can be sorted by date descending' do
          date_desc = @my_finances_details_page.visible_transaction_dates.sort { |x, y| y <=> x }
          @my_finances_details_page.sort_by_date_desc
          wait.until { @my_finances_details_page.visible_transaction_dates == date_desc }
        end
        it 'can be sorted by date ascending' do
          date_asc = @my_finances_details_page.visible_transaction_dates.sort
          @my_finances_details_page.sort_by_date_asc
          wait.until { @my_finances_details_page.visible_transaction_dates == date_asc }
        end
        it 'can be sorted by description ascending alphabetically' do
          descrip_asc = @my_finances_details_page.visible_transaction_descrip.sort
          @my_finances_details_page.sort_by_descrip_asc
          wait.until { @my_finances_details_page.visible_transaction_descrip == descrip_asc }
        end
        it 'can be sorted by description descending alphabetically' do
          descrip_desc = @my_finances_details_page.visible_transaction_descrip.sort { |x, y| y <=> x }
          @my_finances_details_page.sort_by_descrip_desc
          wait.until { @my_finances_details_page.visible_transaction_descrip == descrip_desc }
        end
        it 'can be sorted by amount ascending' do
          amt_asc = @my_finances_details_page.visible_transaction_amts.sort
          @my_finances_details_page.sort_by_amount_asc
          wait.until { @my_finances_details_page.visible_transaction_amts == amt_asc }
        end
        it 'can be sorted by amount descending' do
          amt_desc = @my_finances_details_page.visible_transaction_amts.sort { |x, y| y <=> x }
          @my_finances_details_page.sort_by_amount_desc
          wait.until { @my_finances_details_page.visible_transaction_amts == amt_desc }
        end
        it 'can be sorted by transaction type ascending alphabetically' do
          type_asc = @my_finances_details_page.visible_transaction_types.sort
          @my_finances_details_page.sort_by_trans_type_asc
          wait.until { @my_finances_details_page.visible_transaction_types == type_asc }
        end
        it 'can be sorted by transaction type descending alphabetically' do
          type_desc = @my_finances_details_page.visible_transaction_types.sort { |x, y| y <=> x }
          @my_finances_details_page.sort_by_trans_type_desc
          wait.until { @my_finances_details_page.visible_transaction_types == type_desc }
        end
      end

      it 'shows the last update date' do
        api_date = Time.strptime(@fin_api_page.last_update_date_str, '%Y-%m-%d')
        expect(@my_finances_details_page.last_update_date).to eql(api_date.strftime('%m/%d/%y'))
      end
    end
  end
end
