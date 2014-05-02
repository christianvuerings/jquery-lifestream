require 'rspec'
require 'selenium-webdriver'
require 'page-object'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_finances_page'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/splash_page'
require_relative 'pages/settings_page'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'

describe 'When I visit My Finances' do

  before(:all) do
    @driver = WebDriverUtils.driver
    splash_page = CalCentralPages::SplashPage.new(@driver)
    splash_page.load_page(@driver)
    splash_page.click_sign_in_button(@driver)
    cal_net_page = CalNetPages::CalNetAuthPage.new(@driver)
    cal_net_page.login(UserUtils.oski_username, UserUtils.oski_password)
    @my_finances_page = CalCentralPages::MyFinancesPage.new(@driver)
    @my_finances_page.load_page(@driver)
    @my_finances_page.wait_for_billing_summary
    @my_finances_page.wait_for_fin_resources_links
  end

  context 'cards are present' do
    it 'for Billing Summary' do
      @my_finances_page.billing_summary_heading?.should be_true
    end
    it 'for Cal 1 Card' do
      @my_finances_page.cal_1_card_heading?.should be_true
    end
    it 'for Financial Resources' do
      @my_finances_page.fin_resources_heading?.should be_true
    end
    it 'for Financial Messages' do
      @my_finances_page.fin_messages_heading?.should be_true
    end
  end

  context 'Billing Summary includes' do
    it 'account balance amount' do
      @my_finances_page.account_balance_element?.should be_true
    end
    it 'amount due now' do
      @my_finances_page.amt_due_now_element?.should be_true
    end
  end

  context 'there is a financial resources link to' do
    it 'Cal Student Central' do
      @my_finances_page.cal_student_central_link?.should be_true
    end
    it 'Fin Aid Estimator' do
      @my_finances_page.fin_aid_estimator_link?.should be_true
    end
    it 'Reg Fees' do
      @my_finances_page.reg_fees_link?.should be_true
    end
    it 'Student Billing Services' do
      @my_finances_page.student_billing_svcs_link?.should be_true
    end
    it 'Student Budgets' do
      @my_finances_page.student_budgets_link?.should be_true
    end
    it 'Education loan counseling' do
      @my_finances_page.educ_loan_counseling_link?.should be_true
    end
    it 'FAFSA' do
      @my_finances_page.fafsa_link?.should be_true
    end
    it 'Financial Aid' do
      @my_finances_page.fin_aid_link?.should be_true
    end
    it 'MyFinAid' do
      @my_finances_page.my_fin_aid_link?.should be_true
    end
    it 'Grad Loans' do
      @my_finances_page.grad_loans_link?.should be_true
    end
    it 'Graduate Student Financial Support' do
      @my_finances_page.grad_student_fin_support_link?.should be_true
    end
    it 'Scholarship database' do
      @my_finances_page.scholarship_db_link?.should be_true
    end
    it 'Undergrad financial link' do
      @my_finances_page.undergrad_fin_facts_link?.should be_true
    end
    it 'Undergrad loans' do
      @my_finances_page.undergrad_loans_link?.should be_true
    end
  end

  after(:all) do
    @driver.quit
  end

end