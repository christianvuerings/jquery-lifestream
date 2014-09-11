require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_financials_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_details_page'

describe 'My Finances', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.driver
      output_dir = Rails.root.join('tmp', 'ui_selenium_ouput')
      if !File.exists?(output_dir)
        FileUtils.mkdir_p(output_dir)
      end
      test_output = Rails.root.join(output_dir, 'my_finances_data_acct_summary.csv')
      logger.info('Opening output CSV')
      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Finances Tab', 'CARS Data', 'Acct Bal', 'Amt Due Now', 'Past Due', 'Future Activity',
                          'On DPP', 'Norm Install', 'DPP Past Due']
      end
      logger.info('Reading input CSV')
      uids_csv = File.read(WebDriverUtils.live_users)
      logger.info('Parsing UIDs')
      uids = CSV.parse(uids_csv, :headers => true)

      uids.each do |row|
        uid = "#{row['uid']}"
        logger.info('UID is ' + uid)
        has_finances_tab = false
        has_cars_data = false
        acct_bal = false
        amt_due_now = false
        has_past_due_amt = false
        has_future_activity = false
        is_dpp = false
        has_dpp_balance = false
        is_dpp_past_due = false

        begin
          splash_page = CalCentralPages::SplashPage.new(driver)
          splash_page.load_page(driver)
          splash_page.basic_auth(driver, uid)
          status_api_page = ApiMyStatusPage.new(driver)
          status_api_page.get_json(driver)
          has_finances_tab = status_api_page.has_finances_tab?
          fin_api_page = ApiMyFinancialsPage.new(driver)
          fin_api_page.get_json(driver)
          my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesDetailsPage.new(driver)
          my_finances_page.load_page(driver)
          my_finances_page.wait_for_billing_summary(driver)

          my_fin_no_cars_msg = my_finances_page.has_no_cars_data_msg?

          if fin_api_page.has_cars_data?
            has_cars_data = true
            it 'does not show a no-data message for UID ' + uid do
              my_fin_no_cars_msg.should be_false
            end

            # API DATA SANITY TESTS
            it 'shows an account balance that is equal to the sum of the amount due now plus the amount not yet due for UID ' + uid do
              BigDecimal.new(fin_api_page.account_balance_str).should eql(BigDecimal.new(fin_api_page.min_amt_due_str) +
                BigDecimal.new(fin_api_page.future_activity_str))
            end
            if fin_api_page.account_balance >= 0
              it 'shows an account balance that is greater than or equal to the minimum amount due now for UID ' + uid do
                fin_api_page.account_balance.should be >= fin_api_page.min_amt_due
              end
              it 'shows an account balance that is greater than or equal to the past due amount for UID ' + uid do
                fin_api_page.account_balance.should be >= fin_api_page.past_due_amt
              end
              it 'shows an account balance that is greater than or equal to the amount not yet due for UID ' + uid do
                fin_api_page.account_balance.should be >= fin_api_page.future_activity
              end
              it 'shows an account balance that is greater than or equal to the DPP balance for UID ' + uid do
                fin_api_page.account_balance.should be >= fin_api_page.dpp_balance
              end
            end

            # ACCOUNT BALANCE
            my_fin_acct_bal = my_finances_page.account_balance
            if fin_api_page.account_balance > 0
              acct_bal = 'Positive'
            elsif fin_api_page.account_balance == 0
              acct_bal = 'Zero'
            elsif fin_api_page.account_balance < 0
              acct_bal = 'Negative'
            end
            it 'shows the right account balance for UID ' + uid do
              my_fin_acct_bal.should eql(fin_api_page.account_balance_str)
            end

            # AMOUNT DUE NOW
            my_fin_amt_due_label = my_finances_page.amt_due_now_label
            if fin_api_page.min_amt_due > 0
              amt_due_now = 'Positive'
              it 'shows the label Amount Due Now for UID ' + uid do
                my_fin_amt_due_label.should include('Amount Due Now')
              end
            elsif fin_api_page.min_amt_due == 0
              amt_due_now = 'Zero'
              it 'shows the label Amount Due Now for UID ' + uid do
                my_fin_amt_due_label.should include('Amount Due Now')
              end
            elsif fin_api_page.min_amt_due < 0
              amt_due_now = 'Negative'
              it 'shows the label Credit Balance for UID ' + uid do
                my_fin_amt_due_label.should include('Credit Balance')
              end
            end
            my_fin_amt_due_now = my_finances_page.amt_due_now
            it 'shows the right amount due now for UID ' + uid do
              my_fin_amt_due_now.should eql(fin_api_page.min_amt_due_str)
            end

            # PAST DUE AMOUNT
            if fin_api_page.past_due_amt > 0
              has_past_due_amt = true
              my_fin_past_due_bal = my_finances_page.past_due_amt
              it 'shows the past due amount for UID ' + uid do
                my_fin_past_due_bal.should eql(fin_api_page.past_due_amt_str)
              end
            end

            # CHARGES NOT YET DUE
            if fin_api_page.future_activity > 0
              has_future_activity = true
              my_fin_future_activity = my_finances_page.charges_not_due
              it 'shows the charges not yet due for UID ' + uid do
                my_fin_future_activity.should eql(fin_api_page.future_activity_str)
              end
            end

            # MAKE PAYMENT LINK
            my_fin_pmt_link = my_finances_page.make_payment_link?
            if fin_api_page.account_balance != 0
              it 'shows make payment link for UID ' + uid do
                my_fin_pmt_link.should be_true
              end
            end

            # LAST STATEMENT BALANCE
            my_finances_page.click_account_balance(driver)
            my_fin_last_bal = my_finances_page.last_statement_balance
            it 'shows the right last statement balance for UID ' + uid do
              my_fin_last_bal.should eql(fin_api_page.last_statement_balance_str)
            end

            # DPP
            my_fin_dpp_bal_element = my_finances_page.dpp_balance_element?
            my_fin_dpp_text = my_finances_page.dpp_text?
            my_fin_dpp_install_element = my_finances_page.dpp_normal_install_element?
            if fin_api_page.is_on_dpp?
              is_dpp = true
              my_fin_dpp_bal = my_finances_page.dpp_balance
              it 'shows DPP balance for UID ' + uid do
                my_fin_dpp_bal.should eql(fin_api_page.dpp_balance_str)
              end
              it 'shows DPP informational text for UID ' + uid do
                my_fin_dpp_text.should be_true
              end
              if fin_api_page.dpp_balance > 0
                has_dpp_balance = true
                my_fin_dpp_install = my_finances_page.dpp_normal_install
                it 'shows DPP normal installment amount for UID ' + uid do
                  my_fin_dpp_install.should eql(fin_api_page.dpp_norm_install_amt_str)
                end
              else
                it 'shows no DPP normal installment amount for UID ' + uid do
                  my_fin_dpp_install_element.should be_false
                end
              end
              if fin_api_page.is_dpp_past_due?
                is_dpp_past_due = true
              end
            else
              it 'shows no DPP balance for UID ' + uid do
                my_fin_dpp_bal_element.should be_false
              end
              it 'shows no DPP informational text for UID ' + uid do
                my_fin_dpp_text.should be_false
              end
            end
          else
            it 'shows a no-data message for UID ' + uid do
              my_fin_no_cars_msg.should be_true
            end
          end

          CSV.open(test_output, 'a+') do |user_info_csv|
            user_info_csv << [uid, has_finances_tab, has_cars_data, acct_bal, amt_due_now, has_past_due_amt, has_future_activity,
                              is_dpp, has_dpp_balance, is_dpp_past_due]
          end
        rescue => e
          logger.error e.message + "\n" + e.backtrace.join("\n")
        end
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      logger.info('Quitting the browser')
      driver.quit
    end
  end
end
