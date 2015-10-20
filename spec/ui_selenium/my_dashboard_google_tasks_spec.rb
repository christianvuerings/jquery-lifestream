require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'util/web_driver_utils'
require_relative 'util/user_utils'
require_relative 'pages/cal_net_auth_page'
require_relative 'pages/cal_central_pages'
require_relative 'pages/splash_page'
require_relative 'pages/my_dashboard_page'
require_relative 'pages/my_dashboard_tasks_card'
require_relative 'pages/google_page'

describe 'The My Dashboard task manager', :testui => true do

  if ENV["UI_TEST"]

    today = Date.today
    yesterday = today - 1
    tomorrow = today + 1
    task_wait = WebDriverUtils.google_task_timeout

    before(:all) do
      @driver = WebDriverUtils.launch_browser
    end

    after(:all) do
      WebDriverUtils.quit_browser(@driver)
    end

    before(:context) do
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page
      splash_page.click_sign_in_button
      cal_net_auth_page = CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      settings_page = CalCentralPages::SettingsPage.new(@driver)
      settings_page.load_page
      settings_page.disconnect_bconnected
      google_page = GooglePage.new(@driver)
      google_page.connect_calcentral_to_google(UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      @tasks_card = CalCentralPages::MyDashboardPage::MyDashboardTasksCard.new(@driver)
      @tasks_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
    end

    context 'for Google tasks' do

      before(:example) do
        @tasks_card.delete_all_tasks
      end

      context 'when adding a task' do

        it 'allows a user to create only one task at a time' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.new_task_title_input_element.when_visible(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.new_task_title_input_element.when_not_visible(timeout=task_wait)
        end

        it 'allows a user to cancel the creation of a new task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Cancel Task', WebDriverUtils.ui_date_input_format(today), nil)
          WebDriverUtils.wait_for_element_and_click @tasks_card.cancel_new_task_button_element
          @tasks_card.cancel_new_task_button_element.when_not_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one?).to be false
        end

        it 'requires that a new task have a title' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task(nil, WebDriverUtils.ui_date_input_format(today), nil)
          expect(@tasks_card.add_new_task_button_element.enabled?).to be false
          WebDriverUtils.wait_for_element_and_click @tasks_card.cancel_new_task_button_element
        end

        it 'requires that a new task have a valid date format' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Bad Date Task', '08/08/14', nil)
          @tasks_card.new_task_date_validation_error_element.when_visible(timeout=task_wait)
          expect(@tasks_card.add_new_task_button_element.enabled?).to be false
          expect(@tasks_card.new_task_date_validation_error).to include('Please use mm/dd/yyyy date format')
        end

        it 'allows a user to create a task without a note' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Note-less task', WebDriverUtils.ui_date_input_format(today), nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          @tasks_card.today_task_one_notes_input_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_notes_input).to eql('')
        end
        it 'allows the user to show more overdue tasks in ascending date order' do
          (1..11).each do |i|
            date = today - i
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @tasks_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @tasks_card.overdue_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @tasks_card.overdue_show_more_button
            end
            @tasks_card.wait_until(task_wait) { @tasks_card.overdue_task_one_title == "task #{i.to_s}" }
            @tasks_card.wait_until(task_wait) { @tasks_card.overdue_task_one_date == WebDriverUtils.ui_numeric_date_format(date) }
            expect(@tasks_card.overdue_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more tasks due today in ascending creation sequence' do
          (1..11).each do |i|
            date = today
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @tasks_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @tasks_card.today_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @tasks_card.today_show_more_button
            end
            @tasks_card.wait_until(task_wait) { @tasks_card.last_today_task_title == "task #{i.to_s}" }
            @tasks_card.wait_until(task_wait) { @tasks_card.last_today_task_date == WebDriverUtils.ui_numeric_date_format(date) }
            expect(@tasks_card.today_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more tasks due in the future in ascending date order' do
          (1..11).each do |i|
            date = today + i
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("task #{i.to_s}", WebDriverUtils.ui_date_input_format(date), nil)
            @tasks_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @tasks_card.future_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @tasks_card.future_show_more_button
            end
            @tasks_card.wait_until(task_wait) { @tasks_card.last_future_task_title == "task #{i.to_s}" }
            @tasks_card.wait_until(task_wait) { @tasks_card.last_future_task_date == WebDriverUtils.ui_numeric_date_format(date) }
            expect(@tasks_card.future_task_count).to eql(i.to_s)
          end
        end

        it 'allows the user to show more unscheduled tasks in descending creation sequence' do
          (1..11).each do |i|
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("task #{i.to_s}", nil, nil)
            @tasks_card.click_add_task_button
            if i > 1 && (i-1) % 10 == 0
              @tasks_card.unsched_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
              @tasks_card.unsched_show_more_button
            end
            @tasks_card.wait_until(task_wait) { @tasks_card.unsched_task_one_title == "task #{i.to_s}" }
            @tasks_card.wait_until(task_wait) { @tasks_card.unsched_task_one_date == WebDriverUtils.ui_numeric_date_format(today) }
            expect(@tasks_card.unsched_task_count).to eql(i.to_s)
          end
        end
      end

      context 'when editing an existing task' do

        it 'allows a user to edit the title of an existing task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Original Title', WebDriverUtils.ui_date_input_format(today), nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.today_task_one_element.when_present(timeout=task_wait)
          expect(@tasks_card.today_task_one_title).to eql('Original Title')
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          @tasks_card.edit_today_task_one('Edited Title', nil, nil)
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_save_button_element
          @tasks_card.wait_until(task_wait) { @tasks_card.today_task_one_title == 'Edited Title' }
        end

        it 'requires that an edited task have a title' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Task Must Have a Title', WebDriverUtils.ui_date_input_format(today), nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_title).to eql('Task Must Have a Title')
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          @tasks_card.edit_today_task_one('', nil, nil)
          expect(@tasks_card.today_task_one_save_button_element.enabled?).to be false
        end

        it 'allows a user to make an unscheduled task overdue' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Unscheduled task that will be due yesterday', nil, nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_tasks_tab_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(yesterday), nil)
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          @tasks_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.overdue_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.overdue_task_one_title).to eql('Unscheduled task that will be due yesterday')
          expect(@tasks_card.overdue_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(yesterday))
        end

        it 'allows a user to make an unscheduled task due today' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Unscheduled task that will be due today', nil, nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_tasks_tab_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(today), nil)
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          @tasks_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_title).to eql('Unscheduled task that will be due today')
          expect(@tasks_card.today_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(today))
        end

        it 'allows a user to make an unscheduled task due in the future' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Unscheduled task that will be scheduled for tomorrow', nil, nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_tasks_tab_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, WebDriverUtils.ui_date_input_format(tomorrow), nil)
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          @tasks_card.unsched_task_one_element.when_not_present(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.future_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.future_task_one_title).to eql('Unscheduled task that will be scheduled for tomorrow')
          expect(@tasks_card.future_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(tomorrow))
        end

        it 'allows a user to make an overdue task unscheduled' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Overdue task that will be unscheduled', WebDriverUtils.ui_date_input_format(yesterday), nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_edit_button_element
          @tasks_card.edit_overdue_task_one(nil, '', nil)
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_save_button_element
          @tasks_card.overdue_task_one_element.when_not_present(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_tasks_tab_element
          @tasks_card.unsched_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.unsched_task_one_title).to eql('Overdue task that will be unscheduled')
          expect(@tasks_card.unsched_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(today))
        end

        it 'requires that an edited task have a valid date format' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Today task', WebDriverUtils.ui_date_input_format(today), nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          @tasks_card.edit_today_task_one(nil, '08/11/14', '')
          expect(@tasks_card.today_task_one_save_button_element.enabled?).to be false
          @tasks_card.today_task_date_validation_error_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_date_validation_error).to include('Please use mm/dd/yyyy date format')
        end

        it 'allows a user to add notes to an existing task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Note-less task', nil, nil)
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, nil, 'A note for the note-less task')
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          @tasks_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@tasks_card.unsched_task_one_notes).to eql('A note for the note-less task')
        end

        it 'allows a user to edit notes on an existing task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Task with a note', nil, 'The original note for this task')
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, nil, 'The edited note for this task')
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          @tasks_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          @tasks_card.wait_until(task_wait) { @tasks_card.unsched_task_one_notes == 'The edited note for this task' }
        end

        it 'allows a user to remove notes from an existing task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Task with a note', nil, 'The note for this task')
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_edit_button_element
          @tasks_card.edit_unsched_task_one(nil, nil, '')
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_task_one_toggle_element
          @tasks_card.unsched_task_one_notes_element.when_visible(timeout=task_wait)
          @tasks_card.wait_until(task_wait) { @tasks_card.unsched_task_one_notes == '' }
        end

        it 'allows a user to edit multiple scheduled tasks at once' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Overdue task', WebDriverUtils.ui_date_input_format(yesterday), 'Overdue task notes')
          @tasks_card.click_add_task_button
          @tasks_card.overdue_task_one_element.when_visible(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Today task', WebDriverUtils.ui_date_input_format(today), 'Today task notes')
          @tasks_card.click_add_task_button
          @tasks_card.today_task_one_element.when_visible(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Future task', WebDriverUtils.ui_date_input_format(tomorrow), 'Future task notes')
          @tasks_card.click_add_task_button
          @tasks_card.future_task_one_element.when_visible(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_edit_button_element
          @tasks_card.edit_overdue_task_one('Overdue task edited', WebDriverUtils.ui_date_input_format(yesterday - 1), 'Overdue task notes edited')
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.future_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.future_task_one_edit_button_element
          @tasks_card.edit_future_task_one('Future task edited', WebDriverUtils.ui_date_input_format(tomorrow + 1), 'Future task notes edited')
          @tasks_card.edit_today_task_one('Today task edited', nil, 'Today task notes edited')
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.future_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_save_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.overdue_task_one_toggle_element
          @tasks_card.wait_until(task_wait) { @tasks_card.overdue_task_one_title == 'Overdue task edited' }
          expect(@tasks_card.overdue_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(yesterday - 1))
          @tasks_card.overdue_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@tasks_card.overdue_task_one_notes).to eql('Overdue task notes edited')
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          @tasks_card.wait_until(task_wait) { @tasks_card.today_task_one_title == 'Today task edited' }
          expect(@tasks_card.today_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(today))
          @tasks_card.today_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_notes).to eql('Today task notes edited')
          WebDriverUtils.wait_for_page_and_click @tasks_card.future_task_one_toggle_element
          @tasks_card.wait_until(task_wait) { @tasks_card.future_task_one_title == 'Future task edited' }
          expect(@tasks_card.future_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(tomorrow + 1))
          @tasks_card.future_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@tasks_card.future_task_one_notes).to eql('Future task notes edited')
        end

        it 'allows a user to cancel the edit of an existing task' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('The original task title', WebDriverUtils.ui_date_input_format(today), 'The original task notes')
          @tasks_card.click_add_task_button
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_edit_button_element
          @tasks_card.edit_today_task_one('The edited task title', WebDriverUtils.ui_date_input_format(tomorrow), 'The edited task notes')
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_cancel_button_element
          WebDriverUtils.wait_for_page_and_click @tasks_card.today_task_one_toggle_element
          @tasks_card.today_task_one_notes_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_title).to eql('The original task title')
          expect(@tasks_card.today_task_one_date).to eql(WebDriverUtils.ui_numeric_date_format(today))
          expect(@tasks_card.today_task_one_notes).to eql('The original task notes')
        end
      end

      context 'when completing tasks' do

        it 'allows the user to show more completed tasks sorted first by descending task date and then by descending task creation date' do
          expected_task_titles = []
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          (1..3).each do |i|
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("overdue task #{i.to_s}", WebDriverUtils.ui_date_input_format(yesterday), nil)
            @tasks_card.click_add_task_button
            @tasks_card.wait_until(task_wait) { @tasks_card.overdue_task_one_title == "overdue task #{i.to_s}" }
            expected_task_titles.push(@tasks_card.overdue_task_one_title)
            @tasks_card.complete_overdue_task_one
          end
          (1..3).each do |i|
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("today task #{i.to_s}", WebDriverUtils.ui_date_input_format(today), nil)
            @tasks_card.click_add_task_button
            @tasks_card.wait_until(task_wait) { @tasks_card.today_task_one_title == "today task #{i.to_s}" }
            expected_task_titles.push(@tasks_card.today_task_one_title)
            @tasks_card.complete_today_task_one
          end
          (1..3).each do |i|
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("future task #{i.to_s}", WebDriverUtils.ui_date_input_format(tomorrow), nil)
            @tasks_card.click_add_task_button
            @tasks_card.wait_until(task_wait) { @tasks_card.future_task_one_title == "future task #{i.to_s}" }
            expected_task_titles.push(@tasks_card.future_task_one_title)
            @tasks_card.complete_future_task_one
          end
          WebDriverUtils.wait_for_page_and_click @tasks_card.unsched_tasks_tab_element
          (1..3).each do |i|
            WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
            @tasks_card.edit_new_task("unscheduled task #{i.to_s}", nil, nil)
            @tasks_card.click_add_task_button
            @tasks_card.wait_until(task_wait) { @tasks_card.unsched_task_one_title == "unscheduled task #{i.to_s}" }
            expected_task_titles.push(@tasks_card.unsched_task_one_title)
            @tasks_card.complete_unsched_task_one
          end
          WebDriverUtils.wait_for_page_and_click @tasks_card.completed_tasks_tab_element
          @tasks_card.completed_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.completed_task_count).to eql('12')
          @tasks_card.completed_show_more_button
          @tasks_card.completed_show_more_button_element.when_not_visible(timeout=task_wait)
          expect(@tasks_card.all_completed_task_titles).to eql(expected_task_titles.reverse!)
        end

        it 'allows the user to mark a completed tasks as un-completed' do
          WebDriverUtils.wait_for_page_and_click @tasks_card.new_task_button_element
          @tasks_card.edit_new_task('Today to be completed', WebDriverUtils.ui_date_input_format(today), nil)
          @tasks_card.click_add_task_button
          @tasks_card.complete_today_task_one
          WebDriverUtils.wait_for_page_and_click @tasks_card.completed_tasks_tab_element
          @tasks_card.completed_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.completed_task_one_title).to eql('Today to be completed')
          @tasks_card.uncomplete_task_one
          @tasks_card.completed_task_one_element.when_not_present(timeout=task_wait)
          WebDriverUtils.wait_for_page_and_click @tasks_card.scheduled_tasks_tab_element
          @tasks_card.today_task_one_element.when_visible(timeout=task_wait)
          expect(@tasks_card.today_task_one_title).to eql('Today to be completed')
        end
      end
    end

  end
end
