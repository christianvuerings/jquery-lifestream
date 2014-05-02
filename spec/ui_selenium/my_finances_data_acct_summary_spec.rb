require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/settings_page'
require_relative 'pages/my_finances_page'
require_relative 'pages/api_my_financials_page'
require_relative 'pages/api_my_status_page'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'

describe 'My Finances Billing Summary card', :testui => true do

  before(:all) do
    @driver = WebDriverUtils.driver
    uids = File.read(ENV['HOME'] + '/.calcentral_config/selenium-uids.csv')
    @uids_csv = CSV.parse(uids, :headers => true)
  end

  after(:all) do
    @driver.quit
  end

  it 'matches API data' do

    cal_net_page = CalNetPages::CalNetAuthPage.new(@driver)
    cal_net_page.load_page(@driver)
    cal_net_page.login_admin
    splash_page = CalCentralPages::SplashPage.new(@driver)
    splash_page.load_page(@driver)
    splash_page.click_sign_in_button(@driver)

    test_output = ENV['HOME'] + '/calcentral-selenium/test-output/my_finances_data_acct_summary.csv'
    CSV.open(test_output, 'wb') do |user_info_csv|
      user_info_csv << ['UID', 'Finances Tab', 'Acct Bal', 'Amt Due Now', 'Past Due', 'On DPP', 'Norm Install', 'DPP Past Due']
    end

    @uids_csv.each do |row|

      begin
        uid = "#{row['uid']}"
        puts '*** Test UID ' + uid + ' ***'
        settings_page = CalCentralPages::SettingsPage.new(@driver)
        settings_page.load_page(@driver)
        UserUtils.view_as(@driver, uid, settings_page, cal_net_page)
        fin_api_page = ApiMyFinancialsPage.new
        fin_api_page.get_json(@driver)
        status_api_page = ApiMyStatusPage.new
        status_api_page.get_json(@driver)

        if status_api_page.has_finances_tab? && fin_api_page.has_cars_data?
          has_finances = true
          my_finances_page = CalCentralPages::MyFinancesPage.new(@driver)
          my_finances_page.load_page(@driver)
          my_finances_page.wait_for_billing_summary

          ### ACCOUNT BALANCE ###
          my_finances_page.account_balance.should eql(fin_api_page.account_balance_str)
          if fin_api_page.account_balance > 0
            acct_bal = 'Positive'
          elsif fin_api_page.account_balance == 0
            acct_bal = 'Zero'
          else
            acct_bal = 'Negative'
          end

          ### MAKE PAYMENT LINK ###
          if fin_api_page.account_balance != 0
            my_finances_page.make_payment_link?.should be_true
          end

          ### LAST STATEMENT AMOUNT ###
          my_finances_page.click_account_balance(@driver)
          my_finances_page.last_statement_balance.should eql(fin_api_page.last_statement_balance_str)

          ### AMOUNT DUE NOW ###
          my_finances_page.amt_due_now.should eql(fin_api_page.min_amt_due_str)
          if fin_api_page.min_amt_due > 0
            my_finances_page.amt_due_now_label.should include('Amount Due Now')
            amt_due_now = 'Positive'
          elsif fin_api_page.min_amt_due == 0
            my_finances_page.amt_due_now_label.should include('Amount Due Now')
            amt_due_now = 'Zero'
          else
            my_finances_page.amt_due_now_label.should include('Credit Balance')
            amt_due_now = 'Negative'
          end

          ### PAST DUE AMOUNT ###
          if fin_api_page.past_due_amt > 0
            my_finances_page.past_due_amt.should eql(fin_api_page.past_due_amt_str)
            past_due_amt = 'Past due'
          else
            past_due_amt = 'No past due'
          end

          ### DEFERRED PAYMENT PLAN ###
          if fin_api_page.is_on_dpp?
            my_finances_page.dpp_balance.should eql(fin_api_page.dpp_balance_str)
            my_finances_page.dpp_text?.should be_true
            dpp = true
          else
            my_finances_page.dpp_balance_element?.should be_false
            my_finances_page.dpp_text?.should be_false
            dpp = false
          end
          if fin_api_page.is_on_dpp? && fin_api_page.dpp_balance > 0
            my_finances_page.dpp_normal_install.should eql(fin_api_page.dpp_norm_install_amt_str)
            dpp_normal_install = true
          else
            my_finances_page.dpp_normal_install_element?.should be_false
            dpp_normal_install = false
          end
          if fin_api_page.is_dpp_past_due?
            dpp_past_due = true
          else
            dpp_past_due = false
          end
        else
          has_finances = false
        end

        CSV.open(test_output, 'a+') do |user_info_csv|
          user_info_csv << [uid, has_finances, acct_bal, amt_due_now, past_due_amt, dpp, dpp_normal_install, dpp_past_due]
        end

        # Stop acting as user
        settings_page.load_page(@driver)
        settings_page.stop_viewing_as_user
      rescue
        puts "An error occurred: #{$!}"
      end

    end

  end

end
