require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require 'csv'
require 'json'
require_relative 'util/web_driver_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_financials_page'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_details_page'

describe 'My Finances activity details', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_output = UserUtils.initialize_output_csv(self)
      test_users = UserUtils.load_test_users
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Has Adjustment', 'Has Award', 'Has Charge', 'Has Payment', 'Has Refund', 'Has Waiver',
                          'Has Unapplied Award', 'Has Partial Payment', 'Has Potential Disburse', 'Error?']
      end

      test_users.each do |user|
        if user['financesDetails']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            fin_api_page = ApiMyFinancialsPage.new(driver)
            fin_api_page.get_json(driver)
            my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesDetailsPage.new(driver)
            my_finances_page.load_page(driver)
            my_finances_page.wait_for_billing_summary(driver)

            if fin_api_page.has_cars_data?
              has_adjustment = false
              has_award = false
              has_charge = false
              has_payment = false
              has_refund = false
              has_waiver = false
              has_unapplied_award = false
              has_partial_payment = false
              has_potential_disburse = false
              threw_error = false
              testable_users.push(uid)

              my_finances_page.select_transactions_filter('All Transactions')
              my_finances_page.keep_showing_more
              api_all_transactions = fin_api_page.all_transactions
              my_finances_all_transactions = my_finances_page.visible_transaction_count
              it "shows all the transactions for UID #{uid}" do
                expect(my_finances_all_transactions).to eql(api_all_transactions.length)
              end
              my_finances_page.select_transactions_filter('Date Range')

              adjustments = fin_api_page.all_transactions_by_type('Adjustment')
              if adjustments.length > 0
                adjustment = adjustments.first
                search_date = Time.parse(fin_api_page.trans_date(adjustment)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(adjustment))
                if my_finances_page.visible_transaction_count == 1
                  has_adjustment = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_adj_date = my_finances_page.trans_date
                  my_fin_adj_desc = my_finances_page.trans_desc
                  my_fin_adj_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_adj_id = my_finances_page.trans_id
                  my_fin_adj_due_date = my_finances_page.trans_due_date
                  my_fin_adj_dept = my_finances_page.trans_dept
                  my_fin_adj_term = my_finances_page.trans_term
                  my_fin_has_adj_disburse = my_finances_page.trans_disburse_date?
                  my_fin_adj_ref_method = my_finances_page.trans_ref_method?
                  my_fin_adj_ref_date = my_finances_page.trans_ref_date?
                  my_fin_adj_ref_action = my_finances_page.trans_ref_action?
                  my_fin_adj_ref_void = my_finances_page.trans_ref_void?
                  api_adj_date = Time.parse(fin_api_page.trans_date(adjustment)).strftime('%m/%d/%y')
                  api_adj_desc = fin_api_page.trans_desc(adjustment)
                  api_adj_amt = fin_api_page.trans_amt_str(adjustment)
                  api_adj_id = fin_api_page.trans_id(adjustment)
                  api_adj_due_date = Time.parse(fin_api_page.trans_due_date(adjustment)).strftime('%m/%d/%y')
                  api_adj_dept = fin_api_page.trans_dept(adjustment)
                  api_adj_term = fin_api_page.trans_term(adjustment)
                  it "shows the adjustment date for UID #{uid}" do
                    expect(my_fin_adj_date).to eql(api_adj_date)
                  end
                  it "shows the adjustment description for UID #{uid}" do
                    expect(my_fin_adj_desc).to eql(api_adj_desc)
                  end
                  it "shows the adjustment amount for UID #{uid}" do
                    expect(my_fin_adj_amt).to eql(api_adj_amt)
                  end
                  it "shows the adjustment transaction ID for UID #{uid}" do
                    expect(my_fin_adj_id).to eql("Transaction #: #{api_adj_id}")
                  end
                  it "shows the adjustment due date for UID #{uid}" do
                    expect(my_fin_adj_due_date).to eql("Due Date: #{api_adj_due_date}")
                  end
                  it "shows the adjustment department for UID #{uid}" do
                    expect(my_fin_adj_dept).to include("Department: #{api_adj_dept}")
                  end
                  it "shows the adjustment term for UID #{uid}" do
                    expect(my_fin_adj_term).to eql("Term: #{api_adj_term}")
                  end
                  it "shows no adjustment potential disbursement date for UID #{uid}" do
                    expect(my_fin_has_adj_disburse).to be false
                  end
                  it "shows no adjustment refund method for UID #{uid}" do
                    expect(my_fin_adj_ref_method).to be false
                  end
                  it "shows no adjustment refund date for UID #{uid}" do
                    expect(my_fin_adj_ref_date).to be false
                  end
                  it "shows no adjustment refund action for UID #{uid}" do
                    expect(my_fin_adj_ref_action).to be false
                  end
                  it "shows no adjustment refund void date for UID #{uid}" do
                    expect(my_fin_adj_ref_void).to be false
                  end
                end
              end

              awards = fin_api_page.all_transactions_by_type('Award')
              if awards.length > 0
                award = awards.first
                search_date = Time.parse(fin_api_page.trans_date(award)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(award))
                if my_finances_page.visible_transaction_count == 1
                  has_award = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_award_date = my_finances_page.trans_date
                  my_fin_award_desc = my_finances_page.trans_desc
                  my_fin_award_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_award_id = my_finances_page.trans_id
                  my_fin_award_has_due_date = my_finances_page.trans_due_date?
                  my_fin_award_dept = my_finances_page.trans_dept
                  my_fin_award_term = my_finances_page.trans_term
                  my_fin_award_has_unapplied = my_finances_page.trans_unapplied?
                  my_fin_award_has_disburse = my_finances_page.trans_disburse_date?
                  my_fin_has_award_ref_method = my_finances_page.trans_ref_method?
                  my_fin_has_award_ref_date = my_finances_page.trans_ref_date?
                  my_fin_has_award_ref_action = my_finances_page.trans_ref_action?
                  my_fin_has_award_ref_void = my_finances_page.trans_ref_void?
                  api_award_date = Time.parse(fin_api_page.trans_date(award)).strftime('%m/%d/%y')
                  api_award_desc = fin_api_page.trans_desc(award)
                  api_award_amt = fin_api_page.trans_amt_str(award)
                  api_award_id = fin_api_page.trans_id(award)
                  api_award_dept = fin_api_page.trans_dept(award)
                  api_award_term = fin_api_page.trans_term(award)
                  api_award_status = fin_api_page.trans_status(award)
                  it "shows he award date for UID #{uid}" do
                    expect(my_fin_award_date).to eql(api_award_date)
                  end
                  it "shows the award description for UID #{uid}" do
                    expect(my_fin_award_desc).to eql(api_award_desc)
                  end
                  it "shows the award amount for UID #{uid}" do
                    expect(my_fin_award_amt).to eql(api_award_amt)
                  end
                  it "shows the award transaction ID for UID #{uid}" do
                    expect(my_fin_award_id).to eql("Transaction #: #{api_award_id}")
                  end
                  it "shows no award due date for UID #{uid}" do
                    expect(my_fin_award_has_due_date).to be false
                  end
                  it "shows the award department for UID #{uid}" do
                    expect(my_fin_award_dept).to include("Department: #{api_award_dept}")
                  end
                  it "shows the award term for UID #{uid}" do
                    expect(my_fin_award_term).to eql("Term: #{api_award_term}")
                  end
                  if api_award_status == 'Unapplied'
                    has_unapplied_award = true
                    it "shows the unapplied award text for UID #{uid}" do
                      expect(my_fin_award_has_unapplied).to be true
                    end
                  else
                    it "shows no unapplied award text for UID #{uid}" do
                      expect(my_fin_award_has_unapplied).to be false
                    end
                  end
                  it "shows no award potential disbursement date for UID #{uid}" do
                    expect(my_fin_award_has_disburse).to be false
                  end
                  it "shows no award refund method for UID #{uid}" do
                    expect(my_fin_has_award_ref_method).to be false
                  end
                  it "shows no award refund date for UID #{uid}" do
                    expect(my_fin_has_award_ref_date).to be false
                  end
                  it "shows no award refund action for UID #{uid}" do
                    expect(my_fin_has_award_ref_action).to be false
                  end
                  it "shows no award refund void date for UID #{uid}" do
                    expect(my_fin_has_award_ref_void).to be false
                  end
                end
              end

              charges = fin_api_page.open_charges
              if charges.length > 0
                charge = charges.first
                search_date = Time.parse(fin_api_page.trans_date(charge)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(charge))
                if my_finances_page.visible_transaction_count == 1
                  has_charge = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_charge_date = my_finances_page.trans_date
                  my_fin_charge_desc = my_finances_page.trans_desc
                  my_fin_charge_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_charge_due_future = my_finances_page.trans_due_future_icon?
                  my_fin_charge_due_now = my_finances_page.trans_due_now_icon?
                  my_fin_charge_due_past = my_finances_page.trans_due_past_icon?
                  my_fin_charge_id = my_finances_page.trans_id
                  my_fin_charge_due_date = my_finances_page.trans_due_date
                  my_fin_charge_dept = my_finances_page.trans_dept
                  my_fin_charge_term = my_finances_page.trans_term
                  my_fin_has_charge_disburse = my_finances_page.trans_disburse_date?
                  my_fin_has_charge_ref_method = my_finances_page.trans_ref_method?
                  my_fin_has_charge_ref_date = my_finances_page.trans_ref_date?
                  my_fin_has_charge_ref_action = my_finances_page.trans_ref_action?
                  my_fin_has_charge_ref_void = my_finances_page.trans_ref_void?
                  api_charge_date = Time.parse(fin_api_page.trans_date(charge)).strftime('%m/%d/%y')
                  api_charge_desc = fin_api_page.trans_desc(charge)
                  api_charge_amt = fin_api_page.trans_amt_str(charge)
                  api_charge_bal = fin_api_page.trans_balance_str(charge)
                  api_charge_id = fin_api_page.trans_id(charge)
                  api_charge_due_date = Time.parse(fin_api_page.trans_due_date(charge)).strftime('%m/%d/%y')
                  api_charge_dept = fin_api_page.trans_dept(charge)
                  api_charge_term = fin_api_page.trans_term(charge)
                  it "shows the charge date for UID #{uid}" do
                    expect(my_fin_charge_date).to eql(api_charge_date)
                  end
                  it "shows the charge description for UID #{uid}" do
                    expect(my_fin_charge_desc).to eql(api_charge_desc)
                  end
                  if fin_api_page.trans_status(charge) == 'Installment' || (api_charge_bal.to_f > 0 && api_charge_bal.to_f != api_charge_amt.to_f)
                    has_partial_payment = true
                    my_finances_orig_amt = my_finances_page.trans_orig_amt.delete('$, ')
                    it "shows the charge balance as the charge amount for UID #{uid}" do
                      expect(my_fin_charge_amt).to eql(api_charge_bal)
                    end
                    it "shows the charge amount as the original amount for UID #{uid}" do
                      expect(my_finances_orig_amt).to include("OriginalAmount:#{api_charge_amt}")
                    end
                  else
                    it "shows the charge amount for UID #{uid}" do
                      expect(my_fin_charge_amt).to eql(api_charge_amt)
                    end
                  end
                  if fin_api_page.trans_status(charge) == 'Past Due'
                    it "shows a past due charge icon for UID #{uid}" do
                      expect(my_fin_charge_due_past).to be true
                    end
                  elsif fin_api_page.trans_status(charge) == 'Current'
                    it "shows a charge due now icon for UID #{uid}" do
                      expect(my_fin_charge_due_now).to be true
                    end
                  elsif fin_api_page.trans_status(charge) == 'Future'
                    it "shows a charge due in the future icon for UID #{uid}" do
                      expect(my_fin_charge_due_future).to be true
                    end
                  end
                  it "shows the charge transaction ID for UID #{uid}" do
                    expect(my_fin_charge_id).to eql("Transaction #: #{api_charge_id}")
                  end
                  it "shows the charge due date for UID #{uid}" do
                    expect(my_fin_charge_due_date).to eql("Due Date: #{api_charge_due_date}")
                  end
                  it "shows the charge department URL for UID #{uid}" do
                    expect(my_fin_charge_dept).to include("Department: #{api_charge_dept}")
                  end
                  it "shows the charge term for UID #{uid}" do
                    expect(my_fin_charge_term).to eql("Term: #{api_charge_term}")
                  end
                  it "shows no charge potential disbursement date for UID #{uid}" do
                    expect(my_fin_has_charge_disburse).to be false
                  end
                  it "shows no charge refund method for UID #{uid}" do
                    expect(my_fin_has_charge_ref_method).to be false
                  end
                  it "shows no charge refund date for UID #{uid}" do
                    expect(my_fin_has_charge_ref_date).to be false
                  end
                  it "shows no charge refund action for UID #{uid}" do
                    expect(my_fin_has_charge_ref_action).to be false
                  end
                  it "shows no charge refund void date for UID #{uid}" do
                    expect(my_fin_has_charge_ref_void).to be false
                  end
                end
              end

              payments = fin_api_page.all_transactions_by_type('Payment')
              if payments.length > 0
                payment = payments.first
                search_date = Time.parse(fin_api_page.trans_date(payment)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(payment))
                if my_finances_page.visible_transaction_count == 1
                  has_payment = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_payment_date = my_finances_page.trans_date
                  my_fin_payment_desc = my_finances_page.trans_desc
                  my_fin_payment_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_payment_id = my_finances_page.trans_id
                  my_fin_payment_due_date = my_finances_page.trans_due_date?
                  my_fin_payment_has_dept = my_finances_page.trans_dept?
                  my_fin_payment_term = my_finances_page.trans_term
                  my_fin_has_payment_disburse = my_finances_page.trans_disburse_date?
                  my_fin_has_payment_ref_method = my_finances_page.trans_ref_method?
                  my_fin_has_payment_ref_date = my_finances_page.trans_ref_date?
                  my_fin_has_payment_ref_action = my_finances_page.trans_ref_action?
                  my_fin_has_payment_ref_void = my_finances_page.trans_ref_void?
                  api_payment_date = Time.parse(fin_api_page.trans_date(payment)).strftime('%m/%d/%y')
                  api_payment_desc = fin_api_page.trans_desc(payment)
                  api_payment_amt = fin_api_page.trans_amt_str(payment)
                  api_payment_id = fin_api_page.trans_id(payment)
                  api_payment_term = fin_api_page.trans_term(payment)
                  api_payment_dept = fin_api_page.trans_dept(payment)
                  api_payment_disburse = fin_api_page.trans_disburse_date(payment)
                  it "shows the payment date for UID #{uid}" do
                    expect(my_fin_payment_date).to eql(api_payment_date)
                  end
                  it "shows the payment description for UID #{uid}" do
                    expect(my_fin_payment_desc).to eql(api_payment_desc)
                  end
                  it "shows the payment amount for UID #{uid}" do
                    expect(my_fin_payment_amt).to eql(api_payment_amt)
                  end
                  it "shows the payment transaction ID for UID #{uid}" do
                    expect(my_fin_payment_id).to eql("Transaction #: #{api_payment_id}")
                  end
                  it "shows no payment due date for UID #{uid}" do
                    expect(my_fin_payment_due_date).to be false
                  end
                  if api_payment_dept == ''
                    it "shows no payment department for UID #{uid}" do
                      expect(my_fin_payment_has_dept).to be false
                    end
                  else
                    my_fin_payment_dept = my_finances_page.trans_dept
                    it "shows the payment department for UID #{uid}" do
                      expect(my_fin_payment_dept).to include("Department: #{api_payment_dept}")
                    end
                  end
                  it "shows the payment term for UID #{uid}" do
                    expect(my_fin_payment_term).to eql("Term: #{api_payment_term}")
                  end
                  if api_payment_disburse.nil?
                    it "shows no payment potential disbursement date for UID #{uid}" do
                      expect(my_fin_has_payment_disburse).to be false
                    end
                  else
                    has_potential_disburse = true
                    my_fin_payment_disburse = my_finances_page.trans_disburse_date
                    it "shows the payment potential disbursement date for UID #{uid}" do
                      expect(my_fin_payment_disburse).to eql("Potential Disbursement Date: #{api_payment_disburse}")
                    end
                  end
                  it "shows no payment refund method for UID #{uid}" do
                    expect(my_fin_has_payment_ref_method).to be false
                  end
                  it "shows no payment refund date for UID #{uid}" do
                    expect(my_fin_has_payment_ref_date).to be false
                  end
                  it "shows no payment refund action for UID #{uid}" do
                    expect(my_fin_has_payment_ref_action).to be false
                  end
                  it "shows no payment refund void date for UID #{uid}" do
                    expect(my_fin_has_payment_ref_void).to be false
                  end
                end
              end

              refunds = fin_api_page.all_transactions_by_type('Refund')
              if refunds.length > 0
                refund = refunds.first
                search_date = Time.parse(fin_api_page.trans_date(refund)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(refund))
                if my_finances_page.visible_transaction_count == 1
                  has_refund = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_ref_date = my_finances_page.trans_date
                  my_fin_ref_desc = my_finances_page.trans_desc
                  my_fin_ref_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_ref_id = my_finances_page.trans_id
                  my_fin_ref_due_date = my_finances_page.trans_due_date?
                  my_fin_ref_dept = my_finances_page.trans_dept
                  my_fin_ref_term = my_finances_page.trans_term
                  my_fin_has_ref_disburse = my_finances_page.trans_disburse_date?
                  my_fin_has_ref_method = my_finances_page.trans_ref_method?
                  my_fin_has_ref_date = my_finances_page.trans_ref_date?
                  my_fin_has_ref_action = my_finances_page.trans_ref_action?
                  my_fin_has_ref_void = my_finances_page.trans_ref_void?
                  api_ref_date = Time.parse(fin_api_page.trans_date(refund)).strftime('%m/%d/%y')
                  api_ref_desc = fin_api_page.trans_desc(refund)
                  api_ref_amt = fin_api_page.trans_amt_str(refund)
                  api_ref_id = fin_api_page.trans_id(refund)
                  api_ref_dept = fin_api_page.trans_dept(refund)
                  api_ref_term = fin_api_page.trans_term(refund)
                  api_ref_method = fin_api_page.trans_refund_method(refund)
                  api_ref_action_date = fin_api_page.trans_refund_last_action_date(refund)
                  api_ref_action = fin_api_page.trans_refund_last_action(refund)
                  api_ref_void_date = fin_api_page.trans_refund_void_date(refund)
                  it "shows the refund date for UID #{uid}" do
                    expect(my_fin_ref_date).to eql(api_ref_date)
                  end
                  it "shows the refund description for UID #{uid}" do
                    expect(my_fin_ref_desc).to eql(api_ref_desc)
                  end
                  it "shows the refund amount for UID #{uid}" do
                    expect(my_fin_ref_amt).to eql(api_ref_amt)
                  end
                  it "shows the refund transaction ID for UID #{uid}" do
                    expect(my_fin_ref_id).to eql("Transaction #: #{api_ref_id}")
                  end
                  it "shows no refund due date for UID #{uid}" do
                    expect(my_fin_ref_due_date).to be false
                  end
                  it "shows the refund department URL for UID #{uid}" do
                    expect(my_fin_ref_dept).to include("Department: #{api_ref_dept}")
                  end
                  it "shows the refund term for UID #{uid}" do
                    expect(my_fin_ref_term).to eql("Term: #{api_ref_term}")
                  end
                  it "shows no potential disbursement date for UID #{uid}" do
                    expect(my_fin_has_ref_disburse).to be false
                  end
                  if api_ref_method == ''
                    it "shows no refund payment method for UID #{uid}" do
                      expect(my_fin_has_ref_method).to be false
                    end
                  else
                    my_fin_refund_method = my_finances_page.trans_ref_method
                    it "shows the refund payment method for UID #{uid}" do
                      expect(my_fin_refund_method).to eql("Payment Method: #{api_ref_method}")
                    end
                  end
                  if api_ref_action_date == ''
                    it "shows no refund action date for UID #{uid}" do
                      expect(my_fin_has_ref_date).to be false
                    end
                  else
                    my_fin_ref_action_date = my_finances_page.trans_ref_date
                    api_date = (Time.parse(api_ref_action_date)).strftime('%m/%d/%y')
                    it "shows the refund action date for UID #{uid}" do
                      expect(my_fin_ref_action_date).to eql ("Action Date: #{api_date}")
                    end
                  end
                  if api_ref_action == ''
                    it "shows no refund action for UID #{uid}" do
                      expect(my_fin_has_ref_action).to be false
                    end
                  else
                    my_fin_refund_action = my_finances_page.trans_ref_action
                    it "shows the refund action for UID #{uid}" do
                      expect(my_fin_refund_action).to eql("Action: #{api_ref_action}")
                    end
                  end
                  if api_ref_void_date == ''
                    it "shows no refund void date for UID #{uid}" do
                      expect(my_fin_has_ref_void).to be false
                    end
                  else
                    my_fin_refund_void = my_finances_page.trans_ref_void
                    api_ref_void_date = (Time.parse(api_ref_void_date)).strftime('%m/%d/%y')
                    it "shows the refund void date for UID #{uid}" do
                      expect(my_fin_refund_void).to eql("Date Voided: #{api_ref_void_date}")
                    end
                  end
                end
              end

              waivers = fin_api_page.all_transactions_by_type('Waiver')
              if waivers.length > 0
                waiver = waivers.first
                search_date = Time.parse(fin_api_page.trans_date(waiver)).strftime('%m/%d/%Y')
                my_finances_page.search_by_dates_and_string(search_date, search_date, fin_api_page.trans_id(waiver))
                if my_finances_page.visible_transaction_count == 1
                  has_waiver = true
                  my_finances_page.toggle_first_trans_detail
                  my_fin_waiver_date = my_finances_page.trans_date
                  my_fin_waiver_desc = my_finances_page.trans_desc
                  my_fin_waiver_amt = my_finances_page.trans_amt.delete('$, ')
                  my_fin_waiver_id = my_finances_page.trans_id
                  my_fin_waiver_due_date = my_finances_page.trans_due_date?
                  my_fin_waiver_dept = my_finances_page.trans_dept
                  my_fin_waiver_term = my_finances_page.trans_term
                  my_fin_waiver_has_disburse = my_finances_page.trans_disburse_date?
                  my_fin_waiver_has_ref_method = my_finances_page.trans_ref_method?
                  my_fin_waiver_has_ref_date = my_finances_page.trans_ref_date? 
                  my_fin_waiver_has_ref_action = my_finances_page.trans_ref_action?
                  my_fin_waiver_has_ref_void = my_finances_page.trans_ref_void?
                  api_waiver_date = Time.parse(fin_api_page.trans_date(waiver)).strftime('%m/%d/%y')
                  api_waiver_desc = fin_api_page.trans_desc(waiver)
                  api_waiver_amt = fin_api_page.trans_amt_str(waiver)
                  api_waiver_id = fin_api_page.trans_id(waiver)
                  api_waiver_dept = fin_api_page.trans_dept(waiver)
                  api_waiver_term = fin_api_page.trans_term(waiver)
                  it "shows the waiver date date for UID #{uid}" do
                    expect(my_fin_waiver_date).to eql(api_waiver_date)
                  end
                  it "shows the waiver description for UID #{uid}" do
                    expect(my_fin_waiver_desc).to eql(api_waiver_desc)
                  end
                  it "shows the waiver amount for UID #{uid}" do
                    expect(my_fin_waiver_amt).to eql(api_waiver_amt)
                  end
                  it "shows the waiver transaction ID for UID #{uid}" do
                    expect(my_fin_waiver_id).to eql("Transaction #: #{api_waiver_id}")
                  end
                  it "shows no waiver due date for UID #{uid}" do
                    expect(my_fin_waiver_due_date).to be false
                  end
                  it "shows the waiver department URL for UID #{uid}" do
                    expect(my_fin_waiver_dept).to include("Department: #{api_waiver_dept}")
                  end
                  it "shows the waiver term for UID #{uid}" do
                    expect(my_fin_waiver_term).to eql("Term: #{api_waiver_term}")
                  end
                  it "shows no waiver potential disbursement date for UID #{uid}" do
                    expect(my_fin_waiver_has_disburse).to be false
                  end
                  it "shows no waiver refund method for UID #{uid}" do
                    expect(my_fin_waiver_has_ref_method).to be false
                  end
                  it "shows no waiver refund action date for UID #{uid}" do
                    expect(my_fin_waiver_has_ref_date).to be false
                  end
                  it "shows no waiver refund action for UID #{uid}" do
                    expect(my_fin_waiver_has_ref_action).to be false
                  end
                  it "shows no waiver refund void for UID #{uid}" do
                    expect(my_fin_waiver_has_ref_void).to be false
                  end
                end
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, has_adjustment, has_award, has_charge, has_payment, has_refund, has_waiver,
                                has_unapplied_award, has_partial_payment,has_potential_disburse, threw_error]
            end
          end
        end
      end

        it 'has CARS data for at least one of the test UIDs' do
          expect(testable_users.any?).to be true
        end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
