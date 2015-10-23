require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_academics_status_and_blocks_card'
require_relative 'pages/my_academics_profile_card'
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
        user_info_csv << ['UID', 'Student', 'Registered', 'Resident', 'Active Block', 'Block Types', 'Block History']
      end

      test_users.each do |user|
        if user['status']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          api_reg_status = nil
          api_res_status = nil
          has_active_block = nil
          block_types = nil
          has_block_history = nil

          begin
            splash_page = CalCentralPages::SplashPage.new(driver)
            splash_page.load_page
            splash_page.basic_auth uid
            status_api_page = ApiMyStatusPage.new(driver)
            status_api_page.get_json(driver)
            academics_api_page = ApiMyAcademicsPage.new(driver)
            academics_api_page.get_json(driver)
            badges_api_page = ApiMyBadgesPage.new(driver)
            badges_api_page.get_json(driver)
            my_academics_page = CalCentralPages::MyAcademicsStatusAndBlocksCard.new(driver)
            my_academics_page.load_page

            # STATUS POPOVER

            has_popover = my_academics_page.status_popover_visible?

            if has_popover
              my_academics_page.open_status_popover
              has_reg_alert = my_academics_page.reg_status_alert_element.visible?
              has_block_alert = my_academics_page.block_status_alert_element.visible?
            else
              has_reg_alert = false
              has_block_alert = false
            end

            is_student = status_api_page.is_student?
            if is_student

              it "is available via a person icon in the header for UID #{uid}" do
                expect(has_popover).to be true
              end

              profile_card = CalCentralPages::MyAcademicsProfileCard.new(driver)
              profile_card.name_element.when_visible(timeout=WebDriverUtils.page_load_timeout)

              # REGISTRATION STATUS

              academics_api_page.transition_term? ?
                  api_reg_status = academics_api_page.trans_term_registered? :
                  api_reg_status = status_api_page.is_registered?
              api_reg_status_explanation = badges_api_page.reg_status_explanation

              my_acad_reg_status_summary = my_academics_page.reg_status_summary
              my_acad_reg_status_explanation = my_academics_page.reg_status_explanation
              testable_users << uid if my_acad_reg_status_summary == 'Registered'

              # Currently registered users always see 'registered' messaging regardless of term
              if api_reg_status
                it "shows 'Registered' for UID #{uid}" do
                  expect(my_acad_reg_status_summary).to eql('Registered')
                end
                it "shows a you-are-registered explanation for UID #{uid}" do
                  expect(my_acad_reg_status_explanation).to include(api_reg_status_explanation)
                end
                it "does not show a status popover registration alert for UID #{uid}" do
                  expect(has_reg_alert).to be false
                end
              end

              # During term transitions (i.e., summer and winter break)
              has_term_transition_msg = profile_card.term_transition_msg?
              has_term_transition_msg ? term_transition_msg = profile_card.term_transition_msg : term_transition_msg = nil

              if academics_api_page.transition_term?
                term_name = academics_api_page.trans_term_name

                # No users will have reg status alert, regardless of reg status
                it "does not show a status popover registration alert during term transition for UID #{uid}" do
                  expect(has_reg_alert).to be false
                end

                # Users registered during the transition term
                if api_reg_status
                  if academics_api_page.trans_term_profile_current?
                    it "shows no 'you are registered' profile message during term transition for UID #{uid}" do
                      expect(has_term_transition_msg).to be false
                    end
                  else
                    it "shows a 'you are registered' profile message during term transition for UID #{uid}" do
                      expect(term_transition_msg).to include("You are registered for the #{term_name} term")
                    end
                  end

                # Users not registered during the transition term
                else
                  if academics_api_page.trans_term_profile_current?
                    it "shows no 'you are not registered' profile message during term transition for UID #{uid}" do
                      expect(has_term_transition_msg).to be false
                    end
                    it "shows 'Not Registered' status summary for UID #{uid}" do
                      expect(my_acad_reg_status_summary).to eql("Not registered for #{term_name}")
                    end

                  else
                    it "shows a 'you are not registered' profile message during term transition for UID #{uid}" do
                      expect(term_transition_msg).to include("You are not officially registered for the #{term_name} term")
                    end
                  end
                end

              # During regular terms (spring and fall)
              else
                it "shows no term transition profile message during the regular term for UID #{uid}" do
                  expect(has_term_transition_msg).to be false
                end

                # Users not registered during the regular term
                unless api_reg_status
                  it "shows a registration alert on the status popover during the regular term for UID #{uid}" do
                    expect(has_reg_alert).to be true
                  end

                  reg_alert_text = my_academics_page.reg_status_alert

                  it "shows a registration alert message on the status popover during the regular term for UID #{uid}" do
                    expect(reg_alert_text).to include('Not Registered')
                  end
                  it "shows 'Not Registered' status during the regular term for UID #{uid}" do
                    expect(my_acad_reg_status_summary).to eql('Not Registered')
                  end
                  it "shows a you-are-not-registered explanation during the regular term for UID #{uid}" do
                    expect(my_acad_reg_status_explanation).to include(api_reg_status_explanation)
                  end
                end
              end

              # CALIFORNIA RESIDENCY

              if academics_api_page.transition_term?

                has_residency_status = my_academics_page.res_status_summary?

                it "shows no residency status for UID #{uid} during the transition term" do
                  expect(has_residency_status).to be false
                end
              else

                api_res_status = badges_api_page.residency_summary
                api_res_needs_action = badges_api_page.residency_needs_action
                my_acad_res_status = my_academics_page.res_status_summary

                it "shows residency status of '#{my_acad_res_status}' for UID #{uid}" do
                  expect(my_acad_res_status).to eql(api_res_status)
                end

                if api_res_needs_action == true
                  has_red_res_status_icon = my_academics_page.res_status_icon_red?
                  it "shows a red residency status icon for UID #{uid}" do
                    expect(has_red_res_status_icon).to be true
                  end
                else
                  has_green_res_status_icon = my_academics_page.res_status_icon_green?
                  it "shows a green residency status icon for UID #{uid}" do
                    expect(has_green_res_status_icon).to be true
                  end
                end
              end

              # ACTIVE BLOCKS

              has_active_block = academics_api_page.active_blocks.any?
              if has_active_block

                # Active blocks on status popover
                my_academics_page.open_status_popover
                popover_block_count = my_academics_page.block_status_alert_number
                academics_api_block_count = academics_api_page.active_blocks.length.to_s
                my_acad_block_count = my_academics_page.active_block_count.to_s

                it "shows a block alert on the status popover for UID #{uid}" do
                  expect(has_block_alert).to be true
                end
                it "shows the number of blocks on the status popover for UID #{uid}" do
                  expect(popover_block_count).to eql(academics_api_block_count)
                end
                it "shows the number of blocks on My Academics for UID #{uid}" do
                  expect(my_acad_block_count).to eql(academics_api_block_count)
                end

                # Active blocks on Academics page
                my_acad_block_types = my_academics_page.active_block_types
                my_acad_block_reasons = my_academics_page.active_block_reasons
                my_acad_block_offices = my_academics_page.active_block_offices
                my_acad_block_dates = my_academics_page.active_block_dates
                block_types = my_acad_block_reasons * ', '

                academics_api_block_types = academics_api_page.active_block_types
                academics_api_block_reasons = academics_api_page.active_block_reasons
                academics_api_block_offices = academics_api_page.active_block_offices
                academics_api_block_dates = academics_api_page.active_block_dates

                it "shows the block type on the academics page for UID #{uid}" do
                  expect(my_acad_block_types).to eql(academics_api_block_types)
                end
                it "shows the block reason on the academics page for UID #{uid}" do
                  expect(my_acad_block_reasons).to eql(academics_api_block_reasons)
                end
                it "shows the block office on the academics page for UID #{uid}" do
                  expect(my_acad_block_offices).to eql(academics_api_block_offices)
                end
                it "shows the block date on the academics page for UID #{uid}" do
                  expect(my_acad_block_dates).to eql(academics_api_block_dates)
                end

              else

                has_no_blocks_message = my_academics_page.no_active_blocks_message?

                it "shows no block alert on the status popover for UID #{uid}" do
                  expect(has_block_alert).to be false
                end
                it "shows a no active blocks message for UID #{uid}" do
                  expect(has_no_blocks_message).to be true
                end
              end

              # BLOCK HISTORY

              has_show_block_history_button = my_academics_page.show_block_history_button?

              has_block_history = academics_api_page.inactive_blocks.any?

              if has_block_history

                it "shows a show-block-history button for UID #{uid}" do
                  expect(has_show_block_history_button).to be true
                end

                my_academics_page.show_block_history

                acad_page_inact_block_types = my_academics_page.inactive_block_types
                acad_page_inact_block_dates = my_academics_page.inactive_block_dates
                acad_page_inact_block_clears = my_academics_page.inactive_block_cleared_dates

                acad_api_inact_block_types = academics_api_page.inactive_block_types
                acad_api_inact_block_dates = academics_api_page.inactive_block_dates
                acad_api_inact_block_clears = academics_api_page.inactive_block_cleared_dates

                has_hide_block_history_button = my_academics_page.hide_block_history_button?
                my_academics_page.hide_block_history
                block_history_visible = my_academics_page.inactive_blocks_table_element.visible?

                it "shows the inactive block type on the academics page for UID #{uid}" do
                  expect(acad_page_inact_block_types).to eql(acad_api_inact_block_types)
                end
                it "shows the inactive block date on the academics page for UID #{uid}" do
                  expect(acad_page_inact_block_dates).to eql(acad_api_inact_block_dates)
                end
                it "shows the inactive block cleared date on the academics page for UID #{uid}" do
                  expect(acad_page_inact_block_clears).to eql(acad_api_inact_block_clears)
                end
                it "shows a hide-block-history button for UID #{uid}" do
                  expect(has_hide_block_history_button).to be true
                end
                it "allows UID #{uid} to hide block history" do
                  expect(block_history_visible).to be false
                end

              else

                has_no_block_history_message = my_academics_page.no_inactive_blocks_message?

                it "shows no show-block-history button for UID #{uid}" do
                  expect(has_show_block_history_button).to be false
                end
                it "shows a no block history message on the academics page for UID #{uid}" do
                  expect(has_no_block_history_message).to be true
                end
              end

              # STATUS POPOVER ALERT LINKS

              dashboard_page = CalCentralPages::MyDashboardPage.new(driver)

              if has_reg_alert
                dashboard_page.load_page
                dashboard_page.wait_for_status_popover
                dashboard_page.open_status_popover
                dashboard_page.click_reg_status_alert
                my_academics_page.status_table_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
                reg_status_link_works = my_academics_page.reg_status_summary_element.visible?

                it "offers a link from the status popover registration alert to the My Academics page for UID #{uid}" do
                  expect(reg_status_link_works).to be true
                end
              end

              if has_block_alert
                dashboard_page.load_page
                dashboard_page.wait_for_status_popover
                dashboard_page.open_status_popover
                dashboard_page.click_block_status_alert
                my_academics_page.active_blocks_heading_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
                block_alert_link_works = my_academics_page.active_blocks_table_element.visible?

                it "offers a link from the status popover active block alert to the My Academics page for UID #{uid}" do
                  expect(block_alert_link_works).to be true
                end
              end

            else
              it "is not available via a person icon in the header for UID #{uid}" do
                expect(has_popover).to be false
              end
            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          ensure
            CSV.open(test_output, 'a+') do |user_info_csv|
              user_info_csv << [uid, is_student, api_reg_status, api_res_status, has_active_block, block_types, has_block_history]
            end
          end
        end
      end

      it 'shows "Registered" for at least one of the test UIDs' do
        expect(testable_users.any?).to be true
      end

    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end
