require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_to_do_card'
require_relative 'pages/google_page'

describe 'The My Dashboard task manager', :testui => true do

  if ENV["UI_TEST"]

    today = Date.today
    yesterday = today - 1
    tomorrow = today + 1
    task_wait = WebDriverUtils.google_task_timeout
    wait_for_task = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.google_task_timeout)

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
      cal_net_auth_page = CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      settings_page = CalCentralPages::SettingsPage.new(@driver)
      settings_page.load_page(@driver)
      settings_page.disconnect_bconnected
      google_page = GooglePage.new(@driver)
      google_page.connect_calcentral_to_google(@driver, UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      @to_do_card = CalCentralPages::MyDashboardPage::MyDashboardToDoCard.new(@driver)
      @to_do_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
    end

    context 'for Google tasks' do

      before(:example) do
        @to_do_card.delete_all_tasks(@driver)
      end

      context 'when adding a task' do

        it 'allows a user to create only one task at a time' do
          @to_do_card.click_new_task_button
          @to_do_card.new_task_title_input_element.when_visible(timeout=task_wait)
          @to_do_card.click_new_task_button
          @to_do_card.new_task_title_input_element.when_not_visible(timeout=task_wait)
        end

        it 'allows a user to cancel the creation of a new task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Cancel Task', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_cancel_new_task_button
          @to_do_card.cancel_new_task_button_element.when_not_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one?).to be false
        end

        it 'requires that a new task have a title' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task(nil, WebDriverUtils.ui_date_input_format(today), nil)
          expect(@to_do_card.add_new_task_button_element.enabled?).to be false
          @to_do_card.click_cancel_new_task_button
        end

        it 'requires that a new task have a valid date format' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Bad Date Task', '08/08/14', nil)
          @to_do_card.new_task_date_validation_error_element.when_visible(timeout=task_wait)
          expect(@to_do_card.add_new_task_button_element.enabled?).to be false
          expect(@to_do_card.new_task_date_validation_error).to include('Please use mm/dd/yyyy date format')
        end

        it 'allows a user to create a task without a note' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Note-less task', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_add_task_button
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.today_task_one_notes_input_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_notes_input).to eql('')
        end
        it 'allows the user to show more overdue tasks in ascending date order' do
          (1..11).each do |i|
            date = today - i
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @to_do_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @to_do_card.overdue_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @to_do_card.overdue_show_more_button
            end
            wait_for_task.until { @to_do_card.overdue_task_one_title == "task #{i.to_s}" }
            wait_for_task.until { @to_do_card.overdue_task_one_date == WebDriverUtils.ui_date_display_format(date) }
            expect(@to_do_card.overdue_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more tasks due today in ascending creation sequence' do
          (1..11).each do |i|
            date = today
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @to_do_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @to_do_card.today_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @to_do_card.today_show_more_button
            end
            wait_for_task.until { @to_do_card.last_today_task_title == "task #{i.to_s}" }
            wait_for_task.until { @to_do_card.last_today_task_date == WebDriverUtils.ui_date_display_format(date) }
            expect(@to_do_card.today_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more tasks due in the future in ascending date order' do
          (1..11).each do |i|
            date = today + i
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @to_do_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @to_do_card.future_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @to_do_card.future_show_more_button
            end
            wait_for_task.until { @to_do_card.last_future_task_title == "task #{i.to_s}" }
            wait_for_task.until { @to_do_card.last_future_task_date == WebDriverUtils.ui_date_display_format(date) }
            expect(@to_do_card.future_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more unscheduled tasks in descending creation sequence' do
          (1..11).each do |i|
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("task #{i.to_s}", nil, nil)
            @to_do_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @to_do_card.unsched_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @to_do_card.unsched_show_more_button
            end
            wait_for_task.until { @to_do_card.unsched_task_one_title == "task #{i.to_s}" }
            wait_for_task.until { @to_do_card.unsched_task_one_date == WebDriverUtils.ui_date_display_format(today) }
            expect(@to_do_card.unsched_task_count).to eql(i.to_s)
          end
        end
      end

      context 'when editing an existing task' do

        it 'allows a user to edit the title of an existing task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Original Title', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_add_task_button
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.today_task_one_element.when_present(timeout=task_wait)
          expect(@to_do_card.today_task_one_title).to eql('Original Title')
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.edit_today_task_one('Edited Title', nil, nil)
          @to_do_card.save_today_task_one_edits
          wait_for_task.until { @to_do_card.today_task_one_title == 'Edited Title' }
        end

        it 'requires that an edited task have a title' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Task Must Have a Title', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_add_task_button
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_title).to eql('Task Must Have a Title')
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.edit_today_task_one('', nil, nil)
          expect(@to_do_card.today_task_one_save_button_element.enabled?).to be false
        end

        it 'allows a user to make an unscheduled task overdue' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Unscheduled task that will be due yesterday', nil, nil)
          @to_do_card.click_add_task_button
          @to_do_card.click_unscheduled_tasks_tab
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(yesterday), nil)
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.overdue_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.overdue_task_one_title).to eql('Unscheduled task that will be due yesterday')
          expect(@to_do_card.overdue_task_one_date).to eql(WebDriverUtils.ui_date_display_format(yesterday))
        end

        it 'allows a user to make an unscheduled task due today' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Unscheduled task that will be due today', nil, nil)
          @to_do_card.click_add_task_button
          @to_do_card.click_unscheduled_tasks_tab
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_title).to eql('Unscheduled task that will be due today')
          expect(@to_do_card.today_task_one_date).to eql(WebDriverUtils.ui_date_display_format(today))
        end

        it 'allows a user to make an unscheduled task due in the future' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Unscheduled task that will be scheduled for tomorrow', nil, nil)
          @to_do_card.click_add_task_button
          @to_do_card.click_unscheduled_tasks_tab
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(tomorrow), nil)
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.future_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.future_task_one_title).to eql('Unscheduled task that will be scheduled for tomorrow')
          expect(@to_do_card.future_task_one_date).to eql(WebDriverUtils.ui_date_display_format(tomorrow))
        end

        it 'allows a user to make an overdue task unscheduled' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Overdue task that will be unscheduled', WebDriverUtils.ui_date_input_format(yesterday), nil)
          @to_do_card.click_add_task_button
          @to_do_card.toggle_overdue_task_one_detail
          @to_do_card.click_overdue_task_one_edit_button
          @to_do_card.edit_overdue_task_one(nil, '', nil)
          @to_do_card.save_overdue_task_one_edits
          @to_do_card.overdue_task_one_element.when_not_present(timeout=task_wait)
          @to_do_card.click_unscheduled_tasks_tab
          @to_do_card.unsched_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.unsched_task_one_title).to eql('Overdue task that will be unscheduled')
          expect(@to_do_card.unsched_task_one_date).to eql(WebDriverUtils.ui_date_display_format(today))
        end

        it 'requires that an edited task have a valid date format' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Today task', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_add_task_button
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.edit_today_task_one(nil, '08/11/14', '')
          expect(@to_do_card.today_task_one_save_button_element.enabled?).to be false
          @to_do_card.today_task_date_validation_error_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_date_validation_error).to include('Please use mm/dd/yyyy date format')
        end

        it 'allows a user to add notes to an existing task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Note-less task', nil, nil)
          @to_do_card.click_add_task_button
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, nil, 'A note for the note-less task')
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@to_do_card.unsched_task_one_notes).to eql('A note for the note-less task')
        end

        it 'allows a user to edit notes on an existing task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Task with a note', nil, 'The original note for this task')
          @to_do_card.click_add_task_button
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, nil, 'The edited note for this task')
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          wait_for_task.until { @to_do_card.unsched_task_one_notes == 'The edited note for this task' }
        end

        it 'allows a user to remove notes from an existing task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Task with a note', nil, 'The note for this task')
          @to_do_card.click_add_task_button
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.click_unsched_task_one_edit_button
          @to_do_card.edit_unsched_task_one(nil, nil, '')
          @to_do_card.save_unsched_task_one_edits
          @to_do_card.toggle_unsched_task_one_detail
          @to_do_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          wait_for_task.until { @to_do_card.unsched_task_one_notes == '' }
        end

        it 'allows a user to edit multiple scheduled tasks at once' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Overdue task', WebDriverUtils.ui_date_input_format(yesterday), 'Overdue task notes')
          @to_do_card.click_add_task_button
          @to_do_card.overdue_task_one_element.when_visible(timeout=task_wait)
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Today task', WebDriverUtils.ui_date_input_format(today), 'Today task notes')
          @to_do_card.click_add_task_button
          @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Future task', WebDriverUtils.ui_date_input_format(tomorrow), 'Future task notes')
          @to_do_card.click_add_task_button
          @to_do_card.future_task_one_element.when_visible(timeout=task_wait)
          @to_do_card.toggle_overdue_task_one_detail
          @to_do_card.click_overdue_task_one_edit_button
          @to_do_card.edit_overdue_task_one('Overdue task edited', WebDriverUtils.ui_date_input_format(yesterday - 1), 'Overdue task notes edited')
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.toggle_future_task_one_detail
          @to_do_card.click_future_task_one_edit_button
          @to_do_card.edit_future_task_one('Future task edited', WebDriverUtils.ui_date_input_format(tomorrow + 1), 'Future task notes edited')
          @to_do_card.edit_today_task_one('Today task edited', nil, 'Today task notes edited')
          @to_do_card.save_overdue_task_one_edits
          @to_do_card.save_future_task_one_edits
          @to_do_card.save_today_task_one_edits
          @to_do_card.toggle_overdue_task_one_detail
          wait_for_task.until { @to_do_card.overdue_task_one_title == 'Overdue task edited' }
          expect(@to_do_card.overdue_task_one_date).to eql(WebDriverUtils.ui_date_display_format(yesterday - 1))
          @to_do_card.overdue_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@to_do_card.overdue_task_one_notes).to eql('Overdue task notes edited')
          @to_do_card.toggle_today_task_one_detail
          wait_for_task.until { @to_do_card.today_task_one_title == 'Today task edited' }
          expect(@to_do_card.today_task_one_date).to eql(WebDriverUtils.ui_date_display_format(today))
          @to_do_card.today_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_notes).to eql('Today task notes edited')
          @to_do_card.toggle_future_task_one_detail
          wait_for_task.until { @to_do_card.future_task_one_title == 'Future task edited' }
          expect(@to_do_card.future_task_one_date).to eql(WebDriverUtils.ui_date_display_format(tomorrow + 1))
          @to_do_card.future_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@to_do_card.future_task_one_notes).to eql('Future task notes edited')
        end

        it 'allows a user to cancel the edit of an existing task' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('The original task title', WebDriverUtils.ui_date_input_format(today), 'The original task notes')
          @to_do_card.click_add_task_button
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.click_today_task_one_edit_button
          @to_do_card.edit_today_task_one('The edited task title', WebDriverUtils.ui_date_input_format(tomorrow), 'The edited task notes')
          @to_do_card.cancel_today_task_one_edits
          @to_do_card.toggle_today_task_one_detail
          @to_do_card.today_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_title).to eql('The original task title')
          expect(@to_do_card.today_task_one_date).to eql(WebDriverUtils.ui_date_display_format(today))
          expect(@to_do_card.today_task_one_notes).to eql('The original task notes')
        end
      end

      context 'when completing tasks' do

        it 'allows the user to show more completed tasks sorted first by descending task date and then by descending task creation date' do
          expected_task_titles = []
          @to_do_card.click_scheduled_tasks_tab
          (1..3).each do |i|
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("overdue task #{i.to_s}", WebDriverUtils.ui_date_input_format(yesterday), nil)
            @to_do_card.click_add_task_button
            wait_for_task.until { @to_do_card.overdue_task_one_title == "overdue task #{i.to_s}" }
            expected_task_titles.push(@to_do_card.overdue_task_one_title)
            @to_do_card.complete_overdue_task_one
          end
          (1..3).each do |i|
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("today task #{i.to_s}", WebDriverUtils.ui_date_input_format(today), nil)
            @to_do_card.click_add_task_button
            wait_for_task.until { @to_do_card.today_task_one_title == "today task #{i.to_s}" }
            expected_task_titles.push(@to_do_card.today_task_one_title)
            @to_do_card.complete_today_task_one
          end
          (1..3).each do |i|
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("future task #{i.to_s}", WebDriverUtils.ui_date_input_format(tomorrow), nil)
            @to_do_card.click_add_task_button
            wait_for_task.until { @to_do_card.future_task_one_title == "future task #{i.to_s}" }
            expected_task_titles.push(@to_do_card.future_task_one_title)
            @to_do_card.complete_future_task_one
          end
          @to_do_card.click_unscheduled_tasks_tab
          (1..3).each do |i|
            @to_do_card.click_new_task_button
            @to_do_card.edit_new_task("unscheduled task #{i.to_s}", nil, nil)
            @to_do_card.click_add_task_button
            wait_for_task.until { @to_do_card.unsched_task_one_title == "unscheduled task #{i.to_s}" }
            expected_task_titles.push(@to_do_card.unsched_task_one_title)
            @to_do_card.complete_unsched_task_one
          end
          @to_do_card.click_completed_tasks_tab
          @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.completed_task_count).to eql('12')
          @to_do_card.completed_show_more_button
          @to_do_card.completed_show_more_button_element.when_not_visible(timeout=task_wait)
          expect(@to_do_card.all_completed_task_titles).to eql(expected_task_titles.reverse!)
        end

        it 'allows the user to mark a completed tasks as un-completed' do
          @to_do_card.click_new_task_button
          @to_do_card.edit_new_task('Today to be completed', WebDriverUtils.ui_date_input_format(today), nil)
          @to_do_card.click_add_task_button
          @to_do_card.complete_today_task_one
          @to_do_card.click_completed_tasks_tab
          @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.completed_task_one_title).to eql('Today to be completed')
          @to_do_card.uncomplete_task_one
          @to_do_card.completed_task_one_element.when_not_present(timeout=task_wait)
          @to_do_card.click_scheduled_tasks_tab
          @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@to_do_card.today_task_one_title).to eql('Today to be completed')
        end
      end
    end

  end
end
