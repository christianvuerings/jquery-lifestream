require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative '../util/web_driver_utils'

module CalCentralPages
  module MyFinancesPages
    class MyFinancesLandingPage

      include PageObject
      include CalCentralPages
      include MyFinancesPages
      include ClassLogger

      wait_for_expected_title('My Finances | CalCentral', WebDriverUtils.page_load_timeout)
      h1(:page_heading, :xpath => '//h1[text()="My Finances"]')

      # CAL 1 CARD CARD
      h2(:cal_1_card_heading, :xpath => '//h2[text()="Cal 1 Card"]')

      # FINANCIAL RESOURCES CARD
      h2(:fin_resources_heading, :xpath => '//h2[text()="Financial Resources"]')
      div(:fin_resources_spinner, :xpath => '//h2[text()="Financial Resources"]/../following-sibling::div[@class="cc-spinner"]')
      unordered_list(:fin_resources_list, :xpath => '//ul[@class="cc-list-links"]')
      link(:student_billing_svcs_link, :xpath => '//a[contains(text(),"Billing Services")]')
      link(:ebills_link, :xpath => '//a[contains(text(),"e-bills")]')
      link(:payment_options_link, :xpath => '//a[contains(text(),"Payment Options")]')
      link(:reg_fees_link, :xpath => '//a[contains(text(),"Registration Fees")]')
      link(:tax_1098t_form_link, :xpath => '//a[contains(text(),"Tax 1098-T Form")]')
      link(:fafsa_link, :xpath => '//a[contains(text(),"FAFSA")]')
      link(:fin_aid_scholarships_link, :xpath => '//a[contains(text(),"Financial Aid & Scholarships Office")]')
      link(:grad_fin_support_link, :xpath => '//a[contains(text(),"Graduate Financial Support")]')
      link(:my_fin_aid_link, :xpath => '//a[contains(text(),"MyFinAid")]')
      link(:student_budgets_link, :xpath => '//a[contains(text(),"Student Budgets")]')
      link(:work_study_link, :xpath => '//a[contains(text(),"Work-Study")]')
      link(:have_loan_link, :xpath => '//a[contains(text(),"Have a loan?")]')
      link(:withdraw_cancel_link, :xpath => '//a[contains(text(),"Withdrawing or Canceling?")]')
      link(:sched_and_dead_link, :xpath => '//a[contains(text(),"Schedule & Deadlines")]')
      link(:summer_session_link, :xpath => '//a[contains(text(),"Summer Session")]')
      link(:cal_student_central_link, :xpath => '//a[contains(text(),"Cal Student Central")]')

      # FINANCIAL MESSAGES CARD
      h2(:fin_messages_heading, :xpath => '//h2[text()="Financial Messages"]')

      def load_page(driver)
        logger.info('Loading My Finances landing page')
        driver.get(WebDriverUtils.base_url + '/finances')
      end

      def wait_for_fin_resources_links
        fin_resources_list_element.when_visible(timeout=WebDriverUtils.fin_resources_links_timeout)
      end

      def click_details_link
        details_link
        activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      end

    end
  end
end
