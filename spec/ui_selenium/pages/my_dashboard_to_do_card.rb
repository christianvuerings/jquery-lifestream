require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_dashboard_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  module MyDashboardPage

    class MyDashboardToDoCard

      include PageObject
      include CalCentralPages
      include MyDashboardPage

      # TO DO
      h2(:to_do_heading, :xpath => '//h2[contains(.,"To Do")]')
      button(:completed_tasks_tab, :xpath => '//button[contains(.,"completed")]')
      paragraph(:no_tasks_message, :xpath => '//p[contains(.,"You have no tasks and assignments.")]')
      button(:scheduled_tasks_tab, :xpath => '//button[contains(.,"scheduled")]')
      button(:unsched_tasks_tab, :xpath => '//button[contains(.,"unscheduled")]')
      button(:completed_tasks_tab, :xpath => '//div[@class="cc-widget-tasks-container"]//li[3]/button')

      # ADD/EDIT TASK
      button(:new_task_button, :xpath => '//button[contains(.,"New Task")]')
      text_field(:new_task_title_input, :xpath => '//input[@data-ng-model="addEditTask.title"]')
      text_field(:new_task_date_input, :xpath => '//input[@data-ng-model="addEditTask.dueDate"]')
      text_field(:new_task_notes_input, :xpath => '//textarea[@data-ng-model="addEditTask.notes"]')
      button(:add_new_task_button, :xpath => '//button[contains(.,"Add Task")]')
      button(:cancel_new_task_button, :xpath => '//button[contains(.,"Cancel")]')
      paragraph(:new_task_date_validation_error, :xpath => '//p[@data-ng-show="cc_widget_tasks_form.add_task_due_date.$error.ccDateValidator"]')

      # TASKS: OVERDUE
      span(:overdue_task_count, :xpath => '//span[@data-ng-bind="overdueTasks.length"]')
      list_item(:overdue_task_one, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]')
      link(:overdue_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//span[contains(.,"Show more information about")]')
      button(:overdue_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Edit")]')
      button(:overdue_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Delete")]')
      button(:overdue_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//button[contains(.,"Save")]')
      checkbox(:overdue_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
      div(:overdue_task_one_title, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//strong')
      text_field(:overdue_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@data-ng-model="addEditTask.title"]')
      div(:overdue_task_one_date, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]')
      text_field(:overdue_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//input[@name="add_task_due_date"]')
      div(:overdue_task_one_notes, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
      text_field(:overdue_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in overdueTasks | limitTo: overdueLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
      button(:overdue_show_more_button, :xpath => '//div[@data-cc-show-more-limit="overdueLimit"]/button')

      # TASKS: TODAY
      span(:today_task_count, :xpath => '//span[@data-ng-bind="dueTodayTasks.length"]')
      list_item(:today_task_one, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]')
      link(:today_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//span[contains(.,"Show more information about")]')
      button(:today_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Edit")]')
      button(:today_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Delete")]')
      button(:today_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Save")]')
      button(:today_task_one_cancel_button, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//button[contains(.,"Cancel")][2]')
      checkbox(:today_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
      div(:today_task_one_title, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//strong')
      text_field(:today_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@data-ng-model="addEditTask.title"]')
      div(:today_task_one_date, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]')
      text_field(:today_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//input[@name="add_task_due_date"]')
      div(:today_task_one_notes, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
      text_field(:today_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
      button(:today_show_more_button, :xpath => '//div[@data-cc-show-more-limit="dueTodayLimit"]/button')
      paragraph(:today_task_date_validation_error, :xpath => '//li[@data-ng-repeat="task in dueTodayTasks | limitTo: dueTodayLimit"]//p[@data-ng-show="cc_widget_tasks_form.add_task_due_date.$error.ccDateValidator"]')

      # TASKS: FUTURE
      span(:future_task_count, :xpath => '//span[@data-ng-bind="futureTasks.length"]')
      list_item(:future_task_one, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]')
      link(:future_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//span[contains(.,"Show more information about")]')
      button(:future_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Edit")]')
      button(:future_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Delete")]')
      button(:future_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//button[contains(.,"Save")]')
      checkbox(:future_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
      div(:future_task_one_title, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//strong')
      text_field(:future_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@data-ng-model="addEditTask.title"]')
      div(:future_task_one_date, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//div[@class="cc-widget-tasks-col cc-widget-tasks-col-date"]/span[2]')
      text_field(:future_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//input[@name="add_task_due_date"]')
      div(:future_task_one_notes, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
      text_field(:future_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in futureTasks | limitTo: futureLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
      button(:future_show_more_button, :xpath => '//div[@data-cc-show-more-limit="futureLimit"]/button')

      # TASKS: UNSCHEDULED
      span(:unsched_task_count, :xpath => '//span[@data-ng-bind="unscheduledTasks.length"]')
      list_item(:unsched_task_one, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]')
      link(:unsched_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//span[contains(.,"Show more information about")]')
      button(:unsched_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Edit")]')
      button(:unsched_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Delete")]')
      button(:unsched_task_one_save_button, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//button[contains(.,"Save")]')
      checkbox(:unsched_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
      div(:unsched_task_one_title, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//strong')
      text_field(:unsched_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@data-ng-model="addEditTask.title"]')
      div(:unsched_task_one_date, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//div[@data-ng-show="task.updatedDate && task.bucket === \'Unscheduled\'"]/span')
      text_field(:unsched_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//input[@name="add_task_due_date"]')
      div(:unsched_task_one_notes, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//div[@data-ng-bind-html="task.notes | linky"]')
      text_field(:unsched_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in unscheduledTasks | limitTo:unscheduledLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
      button(:unsched_show_more_button, :xpath => '//div[@data-cc-show-more-limit="unscheduledLimit"]/button')

      # TASKS: COMPLETED
      button(:delete_completed_tasks_button, :xpath => '//button[contains(.,"Delete completed tasks")]')
      span(:completed_task_count, :xpath => '//span[@data-ng-bind="completedTasks.length"]')
      list_item(:completed_task_one, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]')
      link(:completed_task_one_toggle, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//span[contains(.,"Show more information about")]')
      button(:completed_task_one_edit_button, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//button[contains(.,"Edit")]')
      button(:completed_task_one_delete_button, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//button[contains(.,"Delete")]')
      checkbox(:completed_task_one_cbx, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@id="cc-wdiget-tasks-checkbox-0"]')
      div(:completed_task_one_title, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//strong')
      text_field(:completed_task_one_title_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@data-ng-model="addEditTask.title"]')
      text_field(:completed_task_one_date_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//input[@name="add_task_due_date"]')
      text_field(:completed_task_one_notes_input, :xpath => '//li[@data-ng-repeat="task in completedTasks | limitTo:completedLimit"]//textarea[@data-ng-model="addEditTask.notes"]')
      button(:completed_show_more_button, :xpath => '//div[@data-cc-show-more-limit="completedLimit"]/button')

      def load_page(driver)
        MyDashboardPage.load_page(driver)
      end

      # TASK TABS

      def click_scheduled_tasks_tab
        Rails.logger.info('Clicking the scheduled tasks tab')
        scheduled_tasks_tab_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        scheduled_tasks_tab
      end

      def click_unscheduled_tasks_tab
        Rails.logger.info('Clicking the unscheduled tasks tab')
        unsched_tasks_tab_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unsched_tasks_tab
      end

      def click_completed_tasks_tab
        Rails.logger.info('Clicking the completed tasks tab')
        completed_tasks_tab_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        completed_tasks_tab
      end

      # ADD NEW TASK

      def click_new_task_button
        Rails.logger.info('Clicking new task button')
        new_task_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        new_task_button
      end

      def edit_new_task(title, date, note)
        new_task_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unless title.nil?
          Rails.logger.info('Task title is ' + title)
          self.new_task_title_input = title
        end
        unless date.nil?
          Rails.logger.info('Task date is ' + date)
          self.new_task_date_input = date
        end
        unless note.nil?
          Rails.logger.info('Task note is ' + note)
          self.new_task_notes_input = note
        end
      end

      def click_add_task_button
        Rails.logger.info('Clicking add task button')
        add_new_task_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        add_new_task_button
      end

      def click_cancel_new_task_button
        Rails.logger.info('Clicking cancel task button')
        cancel_new_task_button
      end

      # OVERDUE TASKS

      def toggle_overdue_task_one_detail
        overdue_task_one_toggle_element.when_present(timeout=WebDriverUtils.google_task_timeout)
        overdue_task_one_toggle
      end

      def click_overdue_task_one_edit_button
        Rails.logger.info('Clicking edit button for the first overdue task')
        overdue_task_one_edit_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        overdue_task_one_edit_button
      end

      def edit_overdue_task_one(title, date, note)
        overdue_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unless title.nil?
          Rails.logger.info('Task title is ' + title)
          self.overdue_task_one_title_input = title
        end
        unless date.nil?
          Rails.logger.info('Task date is ' + date)
          self.overdue_task_one_date_input = date
        end
        unless note.nil?
          Rails.logger.info('Task note is ' + note)
          self.overdue_task_one_notes_input = note
        end
      end

      def save_overdue_task_one_edits
        Rails.logger.info('Clicking save button for the first overdue task')
        overdue_task_one_save_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        overdue_task_one_save_button
      end

      def cancel_overdue_task_one_edits
        Rails.logger.info('Clicking cancel button for the first overdue task')
        overdue_task_one_cancel_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        overdue_task_one_cancel_button
      end

      def complete_overdue_task_one
        Rails.logger.info('Completing first overdue task')
        overdue_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        check_overdue_task_one_cbx
        sleep(3)
      end

      def delete_all_overdue_tasks(driver)
        Rails.logger.info('Deleting all overdue tasks')
        scheduled_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        scheduled_tasks_tab
        while overdue_task_one_toggle? do
          toggle_overdue_task_one_detail
          overdue_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          overdue_task_one_delete_button
          sleep(3)
        end
      end

      # TODAY'S TASKS

      def toggle_today_task_one_detail
        today_task_one_toggle_element.when_present(timeout=WebDriverUtils.google_task_timeout)
        today_task_one_toggle
      end

      def click_today_task_one_edit_button
        Rails.logger.info('Clicking edit button for the first task due today')
        today_task_one_edit_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        today_task_one_edit_button
      end

      def edit_today_task_one(title, date, note)
        today_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unless title.nil?
          Rails.logger.info('Task title is ' + title)
          self.today_task_one_title_input = title
        end
        unless date.nil?
          Rails.logger.info('Task date is ' + date)
          self.today_task_one_date_input = date
        end
        unless note.nil?
          Rails.logger.info('Task note is ' + note)
          self.today_task_one_notes_input = note
        end
      end

      def save_today_task_one_edits
        Rails.logger.info('Clicking save button for the first task due today')
        today_task_one_save_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        today_task_one_save_button
      end

      def cancel_today_task_one_edits
        Rails.logger.info('Clicking cancel button for the first task due today')
        today_task_one_cancel_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        today_task_one_cancel_button
      end

      def complete_today_task_one
        Rails.logger.info('Completing first task due today')
        today_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        check_today_task_one_cbx
        sleep(3)
      end

      def delete_all_today_tasks(driver)
        Rails.logger.info('Deleting all tasks for today')
        scheduled_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        scheduled_tasks_tab
        while today_task_one_toggle? do
          toggle_today_task_one_detail
          today_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          today_task_one_delete_button
          sleep(3)
        end
      end

      # FUTURE TASKS

      def toggle_future_task_one_detail
        future_task_one_toggle_element.when_present(timeout=WebDriverUtils.google_task_timeout)
        future_task_one_toggle
      end

      def click_future_task_one_edit_button
        Rails.logger.info('Clicking edit button for the first future task')
        future_task_one_edit_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        future_task_one_edit_button
      end

      def edit_future_task_one(title, date, note)
        future_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unless title.nil?
          Rails.logger.info('Task title is ' + title)
          self.future_task_one_title_input = title
        end
        unless date.nil?
          Rails.logger.info('Task date is ' + date)
          self.future_task_one_date_input = date
        end
        unless note.nil?
          Rails.logger.info('Task note is ' + note)
          self.future_task_one_notes_input = note
        end
      end

      def save_future_task_one_edits
        Rails.logger.info('Clicking save button for the first future task')
        future_task_one_save_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        future_task_one_save_button
      end

      def cancel_future_task_one_edits
        Rails.logger.info('Clicking cancel button for the first future task')
        future_task_one_cancel_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        future_task_one_cancel_button
      end

      def complete_future_task_one
        Rails.logger.info('Completing first future task')
        future_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        check_future_task_one_cbx
        sleep(3)
      end

      def delete_all_future_tasks(driver)
        Rails.logger.info('Deleting all future tasks')
        scheduled_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        scheduled_tasks_tab
        while future_task_one_toggle? do
          toggle_future_task_one_detail
          future_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          future_task_one_delete_button
          sleep(3)
        end
      end

      # UNSCHEDULED TASKS

      def toggle_unsched_task_one_detail
        unsched_task_one_toggle_element.when_present(timeout=WebDriverUtils.google_task_timeout)
        unsched_task_one_toggle
      end

      def click_unsched_task_one_edit_button
        Rails.logger.info('Clicking edit button for the first unscheduled task')
        unsched_task_one_edit_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unsched_task_one_edit_button
      end

      def edit_unsched_task_one(title, date, note)
        unsched_task_one_title_input_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unless title.nil?
          Rails.logger.info('New title is ' + title)
          self.unsched_task_one_title_input = title
        end
        unless date.nil?
          Rails.logger.info('New date is ' + date)
          self.unsched_task_one_date_input = date
        end
        unless note.nil?
          Rails.logger.info('Task note is ' + note)
          self.unsched_task_one_notes_input = note
        end
      end

      def save_unsched_task_one_edits
        Rails.logger.info('Clicking save button for the first unscheduled task')
        unsched_task_one_save_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unsched_task_one_save_button
      end

      def cancel_unsched_task_one_edits
        Rails.logger.info('Clicking cancel button for the first unscheduled task')
        unsched_task_one_cancel_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        unsched_task_one_cancel_button
      end

      def complete_unsched_task_one
        Rails.logger.info('Completing first unscheduled task')
        unsched_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        check_unsched_task_one_cbx
        sleep(3)
      end

      def delete_all_unscheduled_tasks(driver)
        Rails.logger.info('Deleting all unscheduled tasks')
        unsched_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        unsched_tasks_tab
        while unsched_task_one_toggle? do
          toggle_unsched_task_one_detail
          unsched_task_one_delete_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          unsched_task_one_delete_button
          sleep(3)
        end
      end

      # COMPLETED TASKS

      def uncomplete_task_one
        Rails.logger.info('Un-completing the first completed task')
        completed_task_one_cbx_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
        uncheck_completed_task_one_cbx
        sleep(3)
      end

      def delete_all_completed_tasks(driver)
        Rails.logger.info('Deleting all completed tasks')
        completed_tasks_tab_element.when_visible(timeout=WebDriverUtils.page_load_timeout)
        completed_tasks_tab
        while completed_task_one_toggle? do
          delete_completed_tasks_button_element.when_visible(timeout=WebDriverUtils.google_task_timeout)
          delete_completed_tasks_button
          wait = Selenium::WebDriver::Wait.new(:timeout => WebDriverUtils.google_task_timeout)
          wait.until { !completed_task_one_toggle? }
        end
      end

      def delete_all_tasks(driver)
        CalCentralPages::MyDashboardPage.load_page(driver)
        self.delete_all_unscheduled_tasks(driver)
        self.delete_all_today_tasks(driver)
        self.delete_all_future_tasks(driver)
        self.delete_all_overdue_tasks(driver)
        self.delete_all_completed_tasks(driver)
        scheduled_tasks_tab
      end
    end
  end
end
