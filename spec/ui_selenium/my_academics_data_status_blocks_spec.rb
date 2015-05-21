require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_academics_status_and_blocks_card'
require_relative 'pages/splash_page'
require_relative 'pages/api_my_badges_page'
require_relative 'pages/api_my_status_page'
require_relative 'pages/api_my_academics_page'

describe 'My Academics Status and Blocks', :testui => true do

  if ENV["UI_TEST"]

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_output = UserUtils.initialize_output_csv(self)
      test_users = UserUtils.load_test_users
      testable_users = []

      CSV.open(test_output, 'wb') do |user_info_csv|
        user_info_csv << ['UID', 'Student', 'Registered', 'Resident', 'Active Block', 'Block Types', 'Block History', 'Error?']
      end

      test_users.each do |user|
        if user['status']
          uid = user['uid'].to_s
          logger.info('UID is ' + uid)
          is_student = false
          is_registered = false
          is_resident = false
          has_active_block = false
          block_type = nil
          has_block_history = false
          threw_error = false

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page(driver)
            splash_page.basic_auth(driver, uid)
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            if status_api_page.is_student?
              is_student = true
              badges_api_page = ApiMyBadgesPage.new(driver)
              badges_api_page.get_json(driver)
              api_reg_status_type = badges_api_page.reg_status_summary
              api_reg_status_explanation = badges_api_page.reg_status_explanation
              api_res_status = badges_api_page.residency_summary
              api_res_needs_action = badges_api_page.residency_needs_action
              academics_page = CalCentralPages::MyAcademicsStatusAndBlocksCard.new(driver)
              academics_api_page = ApiMyAcademicsPage.new(driver)
              academics_api_page.get_json(driver)
              dashboard_page = CalCentralPages::MyDashboardPage.new(driver)
              dashboard_page.load_page(driver)
              has_popover = dashboard_page.status_popover_visible?
              has_no_standing = academics_api_page.has_no_standing?
              if has_no_standing
                it "is not available via a person icon in the header for UID #{uid}" do
                  expect(has_popover).to be false
                end
              else
                it "is available via a person icon in the header for UID #{uid}" do
                  expect(has_popover).to be true
                end
              end

              if has_popover
                testable_users.push(uid)
                dashboard_page.open_status_popover

                # REGISTRATION STATUS
                has_reg_alert = dashboard_page.reg_status_alert_element.visible?
                if api_reg_status_type == 'Registered'
                  is_registered = true
                  it "does not show a registration alert for UID #{uid}" do
                    expect(has_reg_alert).to be false
                  end
                  academics_page.load_page(driver)
                  academics_page.reg_status_summary_element.when_visible(timeout=WebDriverUtils.academics_timeout)
                  has_green_reg_status_icon = academics_page.reg_status_icon_green?
                  it "shows a green reg status icon for UID #{uid}" do
                    expect(has_green_reg_status_icon).to be true
                  end
                  acad_reg_status_summary = academics_page.reg_status_summary
                  it "shows 'Registered' on My Academics for UID #{uid}" do
                    expect(acad_reg_status_summary).to eql(api_reg_status_type)
                  end
                  acad_reg_status_explanation = academics_page.reg_status_explanation
                  it "shows a you-are-registered explanation on My Academics for UID #{uid}" do
                    expect(acad_reg_status_explanation).to include(api_reg_status_explanation)
                  end
                else
                  it "shows a registration alert for UID #{uid}" do
                    expect(has_reg_alert).to be true
                  end
                  reg_alert_text = dashboard_page.reg_status_alert
                  it "shows a registration alert message for UID #{uid}" do
                    expect(reg_alert_text).to include(api_reg_status_type)
                  end
                  dashboard_page.click_reg_status_alert
                  academics_page.page_heading_element.when_visible(timeout=WebDriverUtils.academics_timeout)
                  academics_page.reg_status_summary_element.when_present(timeout=WebDriverUtils.academics_timeout)
                  has_red_reg_status_icon = academics_page.reg_status_icon_red?
                  it "shows a red reg status icon on My Academics for UID #{uid}" do
                    expect(has_red_reg_status_icon).to be true
                  end
                  acad_reg_status_summary = academics_page.reg_status_summary
                  it "shows 'Not Registered' on My Academics for UID #{uid}" do
                    expect(acad_reg_status_summary).to eql(api_reg_status_type)
                  end
                  acad_reg_status_explanation = academics_page.reg_status_explanation
                  it "shows a you-are-not-registered explanation on My Academics for UID #{uid}" do
                    expect(acad_reg_status_explanation).to include(api_reg_status_explanation)
                  end
                end

                # CALIFORNIA RESIDENCY
                acad_res_status = academics_page.res_status_summary
                it "shows residency status of '#{acad_res_status}' for UID #{uid}" do
                  expect(acad_res_status).to eql(api_res_status)
                end
                if acad_res_status == 'Resident'
                  is_resident = true
                end
                if api_res_needs_action == true
                  has_red_res_status_icon = academics_page.res_status_icon_red?
                  it "shows a red residency status icon on My Academics for UID #{uid}" do
                    expect(has_red_res_status_icon).to be true
                  end
                else
                  has_green_res_status_icon = academics_page.res_status_icon_green?
                  it "shows a green residency status icon on My Academics for UID #{uid}" do
                    expect(has_green_res_status_icon).to be true
                  end
                end

                # ACTIVE BLOCKS
                dashboard_page.load_page(driver)
                dashboard_page.wait_for_status_popover
                dashboard_page.open_status_popover
                has_block_alert = dashboard_page.block_status_alert_element.visible?
                if badges_api_page.active_block_needs_action == true
                  has_active_block = true
                  it "shows a block alert for UID #{uid}" do
                    expect(has_block_alert).to be true
                  end
                  badge_api_block_total = badges_api_page.active_block_number_str
                  alert_block_total = dashboard_page.block_status_alert_number
                  it "shows the number of blocks for UID #{uid}" do
                    expect(alert_block_total).to eql(badge_api_block_total)
                  end
                  dashboard_page.click_block_status_alert
                  academics_page.active_blocks_heading_element.when_visible(timeout=WebDriverUtils.academics_timeout)
                  academics_api_block_total = academics_api_page.active_blocks.length
                  acad_block_total = academics_page.active_block_count
                  it "shows the number of blocks on My Academics for UID #{uid}" do
                    expect(acad_block_total).to eql(academics_api_block_total)
                  end
                  it "shows the same number of blocks on My Academics as on the popover for UID #{uid}" do
                    expect(acad_block_total.to_s).to eql(alert_block_total)
                  end
                  academics_page_block_types = academics_page.active_block_types
                  academics_page_block_reasons = academics_page.active_block_reasons
                  block_type = academics_page_block_reasons * ', '
                  academics_page_block_offices = academics_page.active_block_offices
                  academics_page_block_dates = academics_page.active_block_dates
                  academics_api_block_types = academics_api_page.active_block_types
                  academics_api_block_reasons = academics_api_page.active_block_reasons
                  academics_api_block_offices = academics_api_page.active_block_offices
                  academics_api_block_dates = academics_api_page.active_block_dates
                  it "shows the block type on the academics page for UID #{uid}" do
                    expect(academics_page_block_types).to eql(academics_api_block_types)
                  end
                  it "shows the block reason on the academics page for UID #{uid}" do
                    expect(academics_page_block_reasons).to eql(academics_api_block_reasons)
                  end
                  it "shows the block office on the academics page for UID #{uid}" do
                    expect(academics_page_block_offices).to eql(academics_api_block_offices)
                  end
                  it "shows the block date on the academics page for UID #{uid}" do
                    expect(academics_page_block_dates).to eql(academics_api_block_dates)
                  end
                else
                  it "shows no block alert for UID #{uid}" do
                    expect(has_block_alert).to be false
                  end
                  academics_page.load_page(driver)
                  academics_page.active_blocks_heading_element.when_visible(timeout=WebDriverUtils.academics_timeout)
                  has_no_blocks_message = academics_page.no_active_blocks_message?
                  it "shows a no active blocks message on the academics page for UID #{uid}" do
                    expect(has_no_blocks_message).to be true
                  end
                end

                # BLOCK HISTORY
                has_show_block_history_button = academics_page.show_block_history_button?
                if academics_api_page.inactive_blocks.length > 0
                  has_block_history = true
                  it "shows a show-block-history button for UID #{uid}" do
                    expect(has_show_block_history_button).to be true
                  end
                  academics_page.show_block_history
                  acad_page_inact_block_types = academics_page.inactive_block_types
                  acad_page_inact_block_dates = academics_page.inactive_block_dates
                  acad_page_inact_block_clears = academics_page.inactive_block_cleared_dates
                  acad_api_inact_block_types = academics_api_page.inactive_block_types
                  acad_api_inact_block_dates = academics_api_page.inactive_block_dates
                  acad_api_inact_block_clears = academics_api_page.inactive_block_cleared_dates
                  it "shows the inactive block type on the academics page for UID #{uid}" do
                    expect(acad_page_inact_block_types).to eql(acad_api_inact_block_types)
                  end
                  it "shows the inactive block date on the academics page for UID #{uid}" do
                    expect(acad_page_inact_block_dates).to eql(acad_api_inact_block_dates)
                  end
                  it "shows the inactive block cleared date on the academics page for UID #{uid}" do
                    expect(acad_page_inact_block_clears).to eql(acad_api_inact_block_clears)
                  end
                  has_hide_block_history_button = academics_page.hide_block_history_button?
                  it "shows a hide-block-history button for UID #{uid}" do
                    expect(has_hide_block_history_button).to be true
                  end
                  academics_page.hide_block_history
                  block_history_visible = academics_page.inactive_blocks_table_element.visible?
                  it "allows UID #{uid} to hide block history" do
                    expect(block_history_visible).to be false
                  end
                else
                  it "shows no show-block-history button for UID #{uid}" do
                    expect(has_show_block_history_button).to be false
                  end
                  has_no_block_history_message = academics_page.no_inactive_blocks_message?
                  it "shows a no block history message on the academics page for UID #{uid}" do
                    expect(has_no_block_history_message).to be true
                  end
                end
              end

            else
              dashboard_page = CalCentralPages::MyDashboardPage.new(driver)
              dashboard_page.load_page(driver)
              dashboard_page.wait_for_status_popover
              has_popover = dashboard_page.status_icon_element.visible?
              it "are not available to ex-students via a person icon in the header for UID #{uid}" do
                expect(has_popover).to be false
              end
            end
          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
            threw_error = true
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, is_student, is_registered, is_resident, has_active_block, block_type, has_block_history, threw_error]
            end
          end
        end
      end

      it 'has status information for at least one of the test UIDs' do
        expect(testable_users.any?).to be true
      end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
