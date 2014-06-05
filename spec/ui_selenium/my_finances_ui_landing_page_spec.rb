require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_finances_pages'
require_relative 'pages/my_finances_landing_page'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/settings_page'

# TEST DOES NOT INCLUDE CAL 1 CARD OR FIN AID, TO BE TESTED SEPARATELY.

describe 'My Finances landing page', :testui => true do

  if ENV["UI_TEST"] == true

    before(:all) do
      @driver = WebDriverUtils.driver
      # Log into Production CalNet, since a couple links require Prod authentication
      @driver.get('https://auth.berkeley.edu')
      @cal_net_prod_page = CalNetPages::CalNetAuthPage.new(@driver)
      @cal_net_prod_page.login(UserUtils.oski_username, UserUtils.oski_password)
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button(@driver)
      @cal_net_page = CalNetPages::CalNetAuthPage.new(@driver)
      @cal_net_page.login(UserUtils.oski_username, UserUtils.oski_password)
      @my_finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new(@driver)
      @my_finances_page.load_page(@driver)
      @my_finances_page.wait_for_billing_summary(@driver)
      @my_finances_page.wait_for_fin_resources_links
    end

    before(:each) do
      @driver.switch_to.window @driver.window_handles.first
    end

    after(:all) do
      @driver.quit
    end

    context 'card headings' do
      it 'include Cal 1 Card' do
        @my_finances_page.cal_1_card_heading?.should be_true
      end
      it 'include Financial Aid Messages' do
        @my_finances_page.fin_messages_heading?.should be_true
      end
    end

    context 'Billing Summary card' do
      it 'includes the heading Billing Summary' do
        @my_finances_page.billing_summary_heading?.should be_true
      end
      it 'shows CARS account balance amount' do
        @my_finances_page.account_balance_element?.should be_true
      end
      it 'shows CARS amount due now' do
        @my_finances_page.amt_due_now_element?.should be_true
      end
    end

    context 'Financial Resources card' do
      it 'includes the heading Financial Resources' do
        @my_finances_page.fin_resources_heading?.should be_true
      end
      it 'includes a link to Billing Services' do
        @my_finances_page.student_billing_svcs_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Student Billing Services, University of California, Berkeley")]')
        @driver.close
      end
      it 'includes a link to e-bills' do
        @my_finances_page.ebills_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"BearFacts | Welcome to Bear Facts for Students")]')
        @driver.close
      end
      it 'includes a link to Payment Options' do
        @my_finances_page.payment_options_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"CARS Payment Options")]')
        @driver.close
      end
      it 'includes a link to Registration Fees' do
        @my_finances_page.reg_fees_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Registration Fees - Office Of The Registrar")]')
        @driver.close
      end
      it 'includes a link to Tax 1098-T Form' do
        @my_finances_page.tax_1098t_form_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Taxpayer Relief Act of 1997")]')
        @driver.close
      end
      it 'includes a link to FAFSA' do
        @my_finances_page.fafsa_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Home - FAFSA on the Web - Federal Student Aid")]')
        @driver.close
      end
      it 'includes a link to Financial Aid & Scholarships Office' do
        @my_finances_page.fin_aid_scholarships_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Financial Aid and Scholarships | UC Berkeley")]')
        @driver.close
      end
      it 'includes a link to Graduate Financial Support' do
        @my_finances_page.grad_fin_support_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Financial Support for Graduate Students")]')
        @driver.close
      end
      it 'includes a link to MyFinAid' do
        @my_finances_page.my_fin_aid_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"UC Berkeley Financial Aid Web Self Service")]')
        @driver.close
        alert = @driver.switch_to.alert
        alert.accept
      end
      it 'includes a link to Student Budgets' do
        @my_finances_page.student_budgets_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Cost of Attendance | Financial Aid and Scholarships | UC Berkeley")]')
        @driver.close
      end
      it 'includes a link to Work Study' do
        @my_finances_page.work_study_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Work-Study | Financial Aid and Scholarships | UC Berkeley")]')
        @driver.close
      end
      it 'includes a link to Have a loan?' do
        @my_finances_page.have_loan_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Exit Loan Counseling")]')
        @driver.close
      end
      it 'includes a link to Withdrawing or Canceling?' do
        @my_finances_page.withdraw_cancel_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Cancellation,  Withdrawal and Readmission - Office Of The Registrar")]')
        @driver.close
      end
      it 'includes a link to Schedule & Deadlines' do
        @my_finances_page.sched_and_dead_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Schedule | Berkeley Summer Sessions")]')
        @driver.close
      end
      it 'includes a link to Summer Session' do
        @my_finances_page.summer_session_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Berkeley Summer Sessions |")]')
        @driver.close
      end
      it 'includes a link to Cal Student Central' do
        @my_finances_page.cal_student_central_link
        @driver.switch_to.window @driver.window_handles.last
        @driver.find_element(:xpath => '//title[contains(.,"Welcome | Cal Student Central")]')
        @driver.close
      end

    end
  end
end
