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
      @driver = WebDriverUtils.driver
      splash_page = CalCentralPages::SplashPage.new(@driver)
      splash_page.load_page(@driver)
      splash_page.click_sign_in_button(@driver)
      cal_net_auth_page = CalNetPages::CalNetAuthPage.new(@driver)
      cal_net_auth_page.login(UserUtils.qa_username, UserUtils.qa_password)
      settings_page = CalCentralPages::SettingsPage.new(@driver)
      settings_page.load_page(@driver)
      settings_page.disconnect_bconnected(@driver)
      google_page = GooglePage.new(@driver)
      google_page.connect_calcentral_to_google(@driver, UserUtils.qa_gmail_username, UserUtils.qa_gmail_password)
      @to_do_card = CalCentralPages::MyDashboardPage::MyDashboardToDoCard.new(@driver)
      @to_do_card.scheduled_tasks_tab_element.when_present(timeout=WebDriverUtils.page_load_timeout)
    end

    before(:each) do
      @to_do_card.delete_all_tasks(@driver)
    end

    after(:all) do
      @driver.quit
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
        @to_do_card.edit_new_task('Cancel Task', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_cancel_new_task_button
        @to_do_card.cancel_new_task_button_element.when_not_visible(timeout=task_wait)
        @to_do_card.today_task_one?.should be_false
      end

      it 'requires that a new task have a title' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task(nil, today.strftime("%m/%d/%Y"), nil)
        @to_do_card.add_new_task_button_element.enabled?.should be_false
        @to_do_card.click_cancel_new_task_button
      end

      it 'requires that a new task have a valid date format' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Bad Date Task', '08/08/14', nil)
        @to_do_card.new_task_date_validation_error_element.when_visible(timeout=task_wait)
        @to_do_card.add_new_task_button_element.enabled?.should be_false
        @to_do_card.new_task_date_validation_error.should include('Please use mm/dd/yyyy date format')
      end

      it 'allows a user to create a task without a note' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Note-less task', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.today_task_one_notes_input_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_notes_input.should eql('')
      end
    end

    context 'when editing an existing task' do

      it 'allows a user to edit the title of an existing task' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Original Title', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.today_task_one_element.when_present(timeout=task_wait)
        @to_do_card.today_task_one_title.should eql('Original Title')
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.edit_today_task_one('Edited Title', nil, nil)
        @to_do_card.save_today_task_one_edits
        wait_for_task.until { @to_do_card.today_task_one_title == 'Edited Title' }
      end

      it 'requires that an edited task have a title' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Task Must Have a Title', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_title.should eql('Task Must Have a Title')
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.edit_today_task_one('', nil, nil)
        @to_do_card.today_task_one_save_button_element.enabled?.should be_false
      end

      it 'allows a user to make an unscheduled task overdue' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Unscheduled task that will be due yesterday', nil, nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.toggle_unsched_task_one_detail
        @to_do_card.click_unsched_task_one_edit_button
        @to_do_card.edit_unsched_task_one(nil, yesterday.strftime("%m/%d/%Y"), nil)
        @to_do_card.save_unsched_task_one_edits
        @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.overdue_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.overdue_task_one_title.should eql('Unscheduled task that will be due yesterday')
        @to_do_card.overdue_task_one_date.should eql(yesterday.strftime("%m/%d"))
      end

      it 'allows a user to make an unscheduled task due today' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Unscheduled task that will be due today', nil, nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.toggle_unsched_task_one_detail
        @to_do_card.click_unsched_task_one_edit_button
        @to_do_card.edit_unsched_task_one(nil, today.strftime("%m/%d/%Y"), nil)
        @to_do_card.save_unsched_task_one_edits
        @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_title.should eql('Unscheduled task that will be due today')
        @to_do_card.today_task_one_date.should eql(today.strftime("%m/%d"))
      end

      it 'allows a user to make an unscheduled task due in the future' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Unscheduled task that will be scheduled for tomorrow', nil, nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.toggle_unsched_task_one_detail
        @to_do_card.click_unsched_task_one_edit_button
        @to_do_card.edit_unsched_task_one(nil, tomorrow.strftime("%m/%d/%Y"), nil)
        @to_do_card.save_unsched_task_one_edits
        @to_do_card.unsched_task_one_element.when_not_present(timeout=task_wait)
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.future_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.future_task_one_title.should eql('Unscheduled task that will be scheduled for tomorrow')
        @to_do_card.future_task_one_date.should eql(tomorrow.strftime("%m/%d"))
      end

      it 'allows a user to make an overdue task unscheduled' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Overdue task that will be unscheduled', yesterday.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.toggle_overdue_task_one_detail
        @to_do_card.click_overdue_task_one_edit_button
        @to_do_card.edit_overdue_task_one(nil, '', nil)
        @to_do_card.save_overdue_task_one_edits
        @to_do_card.overdue_task_one_element.when_not_present(timeout=task_wait)
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.unsched_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.unsched_task_one_title.should eql('Overdue task that will be unscheduled')
        @to_do_card.unsched_task_one_date.should eql(today.strftime("%m/%d"))
      end

      it 'requires that an edited task have a valid date format' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Today task', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.edit_today_task_one(nil, '08/11/14', '')
        @to_do_card.today_task_one_save_button_element.enabled?.should be_false
        @to_do_card.today_task_date_validation_error_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_date_validation_error.should include('Please use mm/dd/yyyy date format')
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
        @to_do_card.unsched_task_one_notes.should eql('A note for the note-less task')
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
        @to_do_card.edit_new_task('Overdue task', yesterday.strftime("%m/%d/%Y"), 'Overdue task notes')
        @to_do_card.click_add_task_button
        @to_do_card.overdue_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Today task', today.strftime("%m/%d/%Y"), 'Today task notes')
        @to_do_card.click_add_task_button
        @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Future task', tomorrow.strftime("%m/%d/%Y"), 'Future task notes')
        @to_do_card.click_add_task_button
        @to_do_card.future_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.toggle_overdue_task_one_detail
        @to_do_card.click_overdue_task_one_edit_button
        @to_do_card.edit_overdue_task_one('Overdue task edited', (yesterday - 1).strftime("%m/%d/%Y"), 'Overdue task notes edited')
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.toggle_future_task_one_detail
        @to_do_card.click_future_task_one_edit_button
        @to_do_card.edit_future_task_one('Future task edited', (tomorrow + 1).strftime("%m/%d/%Y"), 'Future task notes edited')
        @to_do_card.edit_today_task_one('Today task edited', nil, 'Today task notes edited')
        @to_do_card.save_overdue_task_one_edits
        @to_do_card.save_future_task_one_edits
        @to_do_card.save_today_task_one_edits
        @to_do_card.toggle_overdue_task_one_detail
        wait_for_task.until { @to_do_card.overdue_task_one_title == 'Overdue task edited' }
        @to_do_card.overdue_task_one_date.should eql((yesterday - 1).strftime("%m/%d"))
        @to_do_card.overdue_task_one_notes_element.when_visible(timeout=task_wait)
        @to_do_card.overdue_task_one_notes.should eql('Overdue task notes edited')
        @to_do_card.toggle_today_task_one_detail
        wait_for_task.until { @to_do_card.today_task_one_title == 'Today task edited' }
        @to_do_card.today_task_one_date.should eql(today.strftime("%m/%d"))
        @to_do_card.today_task_one_notes_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_notes.should eql('Today task notes edited')
        @to_do_card.toggle_future_task_one_detail
        wait_for_task.until { @to_do_card.future_task_one_title == 'Future task edited' }
        @to_do_card.future_task_one_date.should eql((tomorrow + 1).strftime("%m/%d"))
        @to_do_card.future_task_one_notes_element.when_visible(timeout=task_wait)
        @to_do_card.future_task_one_notes.should eql('Future task notes edited')
      end

      it 'allows a user to cancel the edit of an existing task' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('The original task title', today.strftime("%m/%d/%Y"), 'The original task notes')
        @to_do_card.click_add_task_button
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.click_today_task_one_edit_button
        @to_do_card.edit_today_task_one('The edited task title', tomorrow.strftime("%m/%d/%Y"), 'The edited task notes')
        @to_do_card.cancel_today_task_one_edits
        @to_do_card.toggle_today_task_one_detail
        @to_do_card.today_task_one_notes_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_title.should eql('The original task title')
        @to_do_card.today_task_one_date.should eql(today.strftime("%m/%d"))
        @to_do_card.today_task_one_notes.should eql('The original task notes')
      end
    end

    it 'allows the user to show more overdue tasks in ascending date order' do
      (1..11).each do |i|
        date = today - i
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('task ' + i.to_s, date.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        if i > 1 && (i-1) % 10 == 0
          @to_do_card.overdue_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          @to_do_card.overdue_show_more_button
        end
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"][' + i.to_s + ']') }
        @to_do_card.overdue_task_count.should eql(i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//strong').text.should eql('task ' + i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]').text.should eql(date.strftime("%m/%d"))
      end
    end

    it 'allows the user to show more tasks due today in ascending creation sequence' do
      (1..11).each do |i|
        date = today
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('task ' + i.to_s, date.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        if i > 1 && (i-1) % 10 == 0
          @to_do_card.today_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          @to_do_card.today_show_more_button
        end
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"][' + i.to_s + ']') }
        @to_do_card.today_task_count.should eql(i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"][' + i.to_s + ']//strong').text.should eql('task ' + i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"][' + i.to_s + ']//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]').text.should eql(date.strftime("%m/%d"))
      end
    end

    it 'allows the user to show more tasks due in the future in ascending date order' do
      (1..11).each do |i|
        date = today + i
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('task ' + i.to_s, date.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        if i > 1 && (i-1) % 10 == 0
          Rails.logger.info('Clicking show more button')
          @to_do_card.future_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          @to_do_card.future_show_more_button
        end
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"][' + i.to_s + ']') }
        @to_do_card.future_task_count.should eql(i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"][' + i.to_s + ']//strong').text.should eql('task ' + i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"][' + i.to_s + ']//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]').text.should eql(date.strftime("%m/%d"))
      end
    end

    it 'allows the user to show more unscheduled tasks in descending creation sequence' do
      (1..11).each do |i|
        date = today
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('task ' + i.to_s, nil, nil)
        @to_do_card.click_add_task_button
        if i > 1 && (i-1) % 10 == 0
          @to_do_card.unsched_show_more_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          @to_do_card.unsched_show_more_button
        end
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"][' + i.to_s + ']') }
        @to_do_card.unsched_task_count.should eql(i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//strong').text.should eql('task ' + i.to_s)
        @driver.find_element(:xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//div[@data-ng-show="task.updatedDate && task.bucket === \'Unscheduled\'"]/span').text.should eql(today.strftime("%m/%d"))
      end
    end

    it 'allows the user to show more completed tasks sorted first by descending task date and then by descending task creation date' do
      @to_do_card.click_scheduled_tasks_tab
      (1..3).each do |i|
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('overdue task ' + i.to_s, yesterday.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//strong[contains(.,"overdue task ' + i.to_s + '")]') }
        @to_do_card.complete_overdue_task_one
      end
      (1..3).each do |i|
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('today task ' + i.to_s, today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//strong[contains(.,"today task ' + i.to_s + '")]') }
        @to_do_card.complete_today_task_one
      end
      (1..3).each do |i|
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('future task ' + i.to_s, tomorrow.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//strong[contains(.,"future task ' + i.to_s + '")]') }
        @to_do_card.complete_future_task_one
      end
      @to_do_card.click_unscheduled_tasks_tab
      (1..3).each do |i|
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('unscheduled task ' + i.to_s, nil, nil)
        @to_do_card.click_add_task_button
        wait_for_task.until { @driver.find_element(:xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//strong[contains(.,"unscheduled task ' + i.to_s + '")]') }
        @to_do_card.complete_unsched_task_one
      end
      @to_do_card.click_completed_tasks_tab
      @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
      @to_do_card.completed_task_count.should eql('12')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][1]//strong').text.should include('unscheduled task 3')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][2]//strong').text.should include('unscheduled task 2')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][3]//strong').text.should include('unscheduled task 1')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][4]//strong').text.should include('future task 3')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][5]//strong').text.should include('future task 2')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][6]//strong').text.should include('future task 1')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][7]//strong').text.should include('today task 3')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][8]//strong').text.should include('today task 2')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][9]//strong').text.should include('today task 1')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][10]//strong').text.should include('overdue task 3')
      @to_do_card.completed_show_more_button
      @to_do_card.completed_show_more_button_element.when_not_visible(timeout=task_wait)
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][11]//strong').text.should include('overdue task 2')
      @driver.find_element(:xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"][12]//strong').text.should include('overdue task 1')
    end

    context 'when completing tasks' do

      it 'allows the user to mark an overdue task as completed' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Overdue to be completed', yesterday.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.complete_overdue_task_one
        @to_do_card.click_completed_tasks_tab
        @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.completed_task_one_title.should eql('Overdue to be completed')
      end

      it 'allows the user to mark a current task as completed' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Today to be completed', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.complete_today_task_one
        @to_do_card.click_completed_tasks_tab
        @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.completed_task_one_title.should eql('Today to be completed')
      end

      it 'allows the user to mark a future task as completed' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Future to be completed', tomorrow.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.complete_future_task_one
        @to_do_card.click_completed_tasks_tab
        @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.completed_task_one_title.should eql('Future to be completed')
      end

      it 'allows the user to mark an unscheduled task as completed' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Unscheduled to be completed', nil, nil)
        @to_do_card.click_add_task_button
        @to_do_card.click_unscheduled_tasks_tab
        @to_do_card.complete_unsched_task_one
        @to_do_card.click_completed_tasks_tab
        @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.completed_task_one_title.should eql('Unscheduled to be completed')
      end

      it 'allows the user to mark a completed tasks as un-completed' do
        @to_do_card.click_new_task_button
        @to_do_card.edit_new_task('Today to be completed', today.strftime("%m/%d/%Y"), nil)
        @to_do_card.click_add_task_button
        @to_do_card.complete_today_task_one
        @to_do_card.click_completed_tasks_tab
        @to_do_card.completed_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.completed_task_one_title.should eql('Today to be completed')
        @to_do_card.uncomplete_task_one
        @to_do_card.completed_task_one_element.when_not_present(timeout=task_wait)
        @to_do_card.click_scheduled_tasks_tab
        @to_do_card.today_task_one_element.when_visible(timeout=task_wait)
        @to_do_card.today_task_one_title.should eql('Today to be completed')
      end
    end
  end
end
