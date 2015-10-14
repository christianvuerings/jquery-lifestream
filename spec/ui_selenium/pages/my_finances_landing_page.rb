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
      div(:cal_1_card_content, :xpath => '//div[@data-ng-if=\'api.user.profile.features.cal1card\']//ul')
      list_item(:card_lost_msg, :xpath => '//li[contains(.,"Your Cal 1 Card is reported as lost.")]')
      list_item(:card_found_msg, :xpath => '//li[@data-ng-if="cal1cardLost === \'Lost\'"]')
      div(:debit_account_header, :xpath => '//div[@class="cc-cal1card-header"]')
      span(:debit_balance, :xpath => '//span[@data-ng-bind="debit + \'\' | currency"]')
      link(:cal_1_card_link, :xpath => '//a[@href="http://cal1card.berkeley.edu"]')
      link(:manage_debit_card, :xpath => '//div[contains(.,"Debit Account")]/following-sibling::a[contains(.,"Manage Your Card")]')
      link(:learn_about_debit_card, :xpath => '//div[contains(.,"You don\'t have a debit account")]/following-sibling::a[contains(.,"Learn more about Cal 1 Card")]')
      span(:meal_points_plan, :xpath => '//span[@data-ng-bind="mealpointsPlan"]')
      span(:meal_points_balance, :xpath => '//span[@data-ng-bind="mealpoints | number"]')
      link(:cal_dining_link, :xpath => '//a[@href="http://caldining.berkeley.edu"]')
      link(:manage_meal_card, :xpath => '//div[contains(.,"Meal Plan")]/following-sibling::a[contains(.,"Manage Your Points")]')
      link(:learn_about_meal_plan, :xpath => '//div[contains(.,"You don\'t have a meal plan")]/following-sibling::a[contains(.,"Learn more about Meal Plans")]')

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

      # FINANCIAL AID MESSAGES CARD
      h2(:fin_messages_heading, :xpath => '//h2[text()="Financial Messages"]')
      div(:no_messages, :xpath => '//div[@data-ng-show="!list.length"]')
      unordered_list(:fin_messages_list, :xpath => '//ul[@class="cc-widget-activities-list"]')
      elements(:finaid_message, :list_item, :xpath => '//ul[@class="cc-widget-activities-list"]/li')
      elements(:finaid_message_sub_activity, :list_item, :xpath => '//ul[@class="cc-widget-activities-list"]/li//li[@data-ng-repeat="subActivity in activity.elements"]')
      elements(:finaid_message_title, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li//strong[@class="ng-binding"][1]')
      elements(:finaid_message_source, :span, :xpath => '//ul[@class="cc-widget-activities-list"]/li//span[@data-ng-bind="activity.source"]')
      elements(:finaid_message_toggle, :link, :xpath => '//ul[@class="cc-widget-activities-list"]/li//div[@data-ng-click="api.widget.toggleShow($event, filteredList, activity, \'Recent Activity\')"]')
      elements(:finaid_message_year, :div, :xpath => '//ul[@class="cc-widget-activities-list"]/li//div[@data-ng-if="activity.termYear"]')
      elements(:finaid_message_icon, :image, :xpath => '//ul[@class="cc-widget-activities-list"]/li//i')
      elements(:finaid_message_link, :link, :xpath => '//ul[@class="cc-widget-activities-list"]/li//a[@data-ng-if="activity.sourceUrl"]')

      def load_page
        logger.info('Loading My Finances landing page')
        navigate_to "#{WebDriverUtils.base_url}/finances"
      end

      def click_details_link
        details_link
        activity_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
      end

      def all_fin_aid_message_titles
        titles = []
        finaid_message_title_elements.each do |msg|
          title = msg.text.gsub(/\s+/, '')
          titles.push(title)
        end
        titles
      end

      def all_fin_aid_message_icons
        icons =[]
        finaid_message_icon_elements.each do |msg|
          icon_type = msg.attribute('class')
          case icon_type
            when 'fa fa-exclamation-circle cc-left'
              icon = 'alert'
            when 'fa fa-info-circle cc-left'
              icon = 'info'
            when 'fa fa-check-circle cc-left'
              icon = 'message'
            when 'fa fa-usd cc-left'
              icon = 'financial'
            else
              icon = nil
          end
          icons.push(icon)
        end
        icons
      end

      def all_fin_aid_message_sources
        sources = []
        finaid_message_source_elements.each do |msg|
          source = msg.text
          sources.push(source)
        end
        sources
      end

      def all_fin_aid_message_years
        years = []
        finaid_message_year_elements.each do |msg|
          year = msg.text
          years.push(year)
        end
        years
      end

      def all_fin_aid_message_dates(messages)
        dates = []
        messages.each do |msg|
          begin
            date_on_page = span_element(:xpath => "//ul[@class='cc-widget-activities-list']/li[#{messages.index(msg) + 1}]//span[@data-ng-if='activity.date']").text
            date = Time.parse(date_on_page).strftime("%-m/%d")
          rescue
            date = nil
          end
          unless date == nil
            dates.push(date)
          end
        end
        dates
      end

      def all_fin_aid_message_links
        links = []
        finaid_message_link_elements.each do |msg|
          link_url = msg.attribute('href').gsub(/\/\s*\z/, '')
          links.push(link_url)
        end
        links
      end

      def all_fin_aid_message_statuses(messages)
        statuses = []
        messages.each do |msg|
          begin
            status = span_element(:xpath => "//ul[@class='cc-widget-activities-list']/li[#{messages.index(msg) + 1}]//span[@data-ng-bind='activity.status']").text
          rescue
            status = nil
          end
          statuses.push(status)
        end
        statuses
      end

      def all_fin_aid_message_summaries(messages)
        summaries = []
        messages.each do |msg|
          begin
            summary_on_page = paragraph_element(:xpath => "//ul[@class='cc-widget-activities-list']/li[#{messages.index(msg) + 1}]//p[@data-ng-bind-html='activity.summary | linky']").text
            summary = summary_on_page.gsub(/\s+/, '')
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            summary = nil
          end
          summaries.push(summary)
        end
        summaries
      end

    end
  end
end
